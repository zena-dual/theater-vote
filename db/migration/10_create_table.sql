-- アイドルテーブル
DROP TABLE IF EXISTS idols;
CREATE TABLE idols (
  id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY
  , type tinyint(1) NOT NULL COMMENT '属性（1: Pr, 2: Fa, 3: An, 0: Ex）'
  , name text NOT NULL COMMENT 'アイドル名'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 劇テーブル
DROP TABLE IF EXISTS dramas;
CREATE TABLE dramas (
  id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY
  , type tinyint(1) NOT NULL COMMENT '種別（1: TA, 2: TB, 3: TC, 4: TD）'
  , name text NOT NULL COMMENT '劇名'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 役テーブル
DROP TABLE IF EXISTS roles;
CREATE TABLE roles (
  id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY
  , drama_id int(11) NOT NULL COMMENT 'ドラマID'
  , name text NOT NULL COMMENT '役名'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
ALTER TABLE roles ADD INDEX roles_index_1 (drama_id);
ALTER TABLE roles ADD CONSTRAINT roles_fk_1
  FOREIGN KEY (drama_id) REFERENCES dramas (id)
  ON DELETE CASCADE ON UPDATE CASCADE;

-- 集計時間テーブル
DROP TABLE IF EXISTS summary_histories;
CREATE TABLE summary_histories (
  id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY
  , role_id int(11) NOT NULL COMMENT '役ID'
  , summarized_at datetime NOT NULL COMMENT '集計日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
ALTER TABLE summary_histories ADD INDEX summary_histories_index_1 (role_id);
ALTER TABLE summary_histories ADD CONSTRAINT summary_histories_fk_1
  FOREIGN KEY (role_id) REFERENCES roles (id)
  ON DELETE CASCADE ON UPDATE CASCADE;

-- レスポンステーブル
DROP TABLE IF EXISTS responses;
CREATE TABLE responses (
  id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY
  , idol_id int(11) NOT NULL COMMENT 'アイドルID'
  , summary_history_id int(11) NOT NULL COMMENT '集計日時ID'
  , score int(11) NOT NULL COMMENT '得票数'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
ALTER TABLE responses ADD INDEX responses_index_1 (idol_id);
ALTER TABLE responses ADD INDEX responses_index_2 (summary_history_id);
ALTER TABLE responses ADD CONSTRAINT responses_fk_1
  FOREIGN KEY (idol_id) REFERENCES idols (id)
  ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE responses ADD CONSTRAINT responses_fk_2
  FOREIGN KEY (summary_history_id) REFERENCES summary_histories (id)
  ON DELETE CASCADE ON UPDATE CASCADE;
