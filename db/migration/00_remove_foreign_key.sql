-- 全ての外部キーを削除するプロシージャ

DROP PROCEDURE IF EXISTS DROP_ALL_FOREIGN_KEY;

DELIMITER $$
CREATE PROCEDURE DROP_ALL_FOREIGN_KEY()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE table_name VARCHAR(64);
  DECLARE key_name VARCHAR(64);
  DECLARE foreign_key_cursor CURSOR FOR
    SELECT
      TABLE_NAME, CONSTRAINT_NAME
      FROM
        INFORMATION_SCHEMA.TABLE_CONSTRAINTS
      WHERE
        TABLE_SCHEMA = DATABASE()
          AND
        CONSTRAINT_TYPE = 'FOREIGN KEY';
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN foreign_key_cursor;

  read_loop: LOOP
    FETCH foreign_key_cursor INTO table_name, key_name;

    IF done THEN
      LEAVE read_loop;
    END IF;

    SET @query = CONCAT('ALTER TABLE ', table_name, ' DROP FOREIGN KEY ', key_name, ';');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END LOOP;

  CLOSE foreign_key_cursor;
END
$$
DELIMITER ;

CALL DROP_ALL_FOREIGN_KEY();

DROP PROCEDURE IF EXISTS DROP_ALL_FOREIGN_KEY;
