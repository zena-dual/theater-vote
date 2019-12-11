from datetime import datetime
import json
import requests

from db_manager import use_manager, use_manager_with_transaction


API_URL = 'https://api.matsurihi.me/mltd/v1/election/current?prettyPrint=false'


def insert_summary_history(role_id: int, summarized_at: datetime):
    """
    レスポンスの取得履歴を insert する
    """

    return use_manager_with_transaction(
        'INSERT INTO summary_histories (role_id, summarized_at) VALUES (%s, %s)',
        (role_id, summarized_at,),
    )


def insert_response(summary_history_id: int, idol_id: int, score: int):
    """
    レスポンス取得時点におけるアイドルのスコアを insert する
    """

    return use_manager_with_transaction(
        '''
          INSERT
            INTO
              responses 
              (summary_history_id, idol_id, score)
            VALUES
              (%s, %s, %s)
        ''',
        (summary_history_id, idol_id, score,),
    )


def get_previous_summarized_at(role_id: int) -> datetime:
    """
    与えられた役IDに紐付く、最も直近のレスポンス取得時刻を取得する
    """

    result = use_manager(
        '''
          SELECT DISTINCT
            summarized_at
            FROM
              summary_histories
            WHERE
              role_id = %s
            ORDER BY
              summarized_at
              DESC
            LIMIT
              1
        ''',
        (role_id,),
    )

    return result[0]['summarized_at'] if result else None


def main():
    response = requests.get(API_URL)
    if response.status_code == requests.codes.ok:
        fetched_json = response.json()
    else:
        with open('/batch/test/test-data.json') as f:
            fetched_json = json.load(f)

    for vote_data_per_role in fetched_json:
        role_id = vote_data_per_role['id']
        summarized_at = datetime.fromisoformat(vote_data_per_role['summaryTime'])
        summarized_at = summarized_at.combine(
            date=summarized_at.date(),
            time=summarized_at.time(),
            tzinfo=None,
        )

        if summarized_at == get_previous_summarized_at(role_id):
            continue

        summary_history_id = insert_summary_history(role_id=role_id, summarized_at=summarized_at)

        for datum in vote_data_per_role['data']:
            insert_response(
                summary_history_id=summary_history_id,
                idol_id=datum['idol_id'],
                score=datum['score']
            )


if __name__ == '__main__':
    main()
