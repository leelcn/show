<?php

function getDb() {

  $dbh = NULL;

  try {
       $dbh = new PDO("pgsql:dbname=sharengo;host=localhost;port=5432", 'sharengo', 'Sharengo1');
  } catch (PDOException $e) {
    echo "-1:Database error : $e";
  }

  return $dbh;
}
 
//$dbsharengo = getDb();

//if ($dbsharengo)
//{
    //echo (__DIR__);
    file_put_contents(__DIR__ . "/db_sql.log", '');
    //$dbsharengo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

    foreach (glob(__DIR__.'/*.*') as $filename) {

        if (is_file($filename))
        {
            $pos1 = strpos($filename, ".disabled");
            $pos2 = strpos($filename, ".php");
            $pos3 = strpos($filename, ".log");
            $pos4 = strpos($filename, ".data");

            // The !== operator can also be used.  Using != would not work as expected
            // because the position of 'a' is 0. The statement (0 != false) evaluates 
            // to false.
            if ($pos1 === false && $pos2 === false && $pos3 === false && $pos4 === false)
            {
                $sql = file_get_contents($filename);
                if ($sql !== FALSE)
                {
			$sql .= ";";
			file_put_contents(__DIR__ . "/db_sql.log", "--- ".$filename."\n".$sql."\n",
				FILE_APPEND);                    
                }
            }
        }
    }

    foreach (glob(__DIR__.'/*.*') as $filename) {

        if (is_file($filename))
        {
            $pos1 = strpos($filename, ".disabled");
            $pos2 = strpos($filename, ".php");
            $pos3 = strpos($filename, ".log");
            $pos4 = strpos($filename, ".sql");

            // The !== operator can also be used.  Using != would not work as expected
            // because the position of 'a' is 0. The statement (0 != false) evaluates 
            // to false.
            if ($pos1 === false && $pos2 === false && $pos3 === false && $pos4 === false)
            {
                $sql = file_get_contents($filename);
                if ($sql !== FALSE)
                {
                	$sql .= ";";
			file_put_contents(__DIR__ . "/db_sql.log", "--- ".$filename."\n".$sql."\n",
				FILE_APPEND);
                }
            }
        }
    }
//}
//else {   
//    echo ("\nNo DB available");
//}
