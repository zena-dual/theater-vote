from db_manager import use_manager, use_manager_with_transaction

def get_previous_response(role_id: int):
    """
    与えられた役IDに紐付く、最も直近のレスポンスを取得する
    """

    return use_manager(
        '''
          SELECT
            i.id
            , i.name
            , r.score
            FROM
              responses AS r
              JOIN (
                SELECT
                  id
                  FROM
                    summary_histories
                  WHERE
                    role_id = %s
                  ORDER BY
                    summarized_at
                    DESC
                  LIMIT
                    1
              ) AS sh
              ON
                r.summary_history_id = sh.id
              JOIN
                idols AS i
                ON
                  r.idol_id = i.id
            ORDER BY
              r.score
              DESC
        ''',
        (role_id,)
    )

if __name__ == '__main__':
    print(get_previous_response(1))
