import mysql.connector
import numpy as np
from tqdm import tqdm
from time import time

NUMBER_OF_GENERATED_SAMPLES = 1000000

def create_listeners_table(db_cursor):
    sql = """
    CREATE TABLE `Listeners` (
        `ListenerId` int(11) NOT NULL AUTO_INCREMENT,
        `FirstName` varchar(255) NOT NULL,
        `LastName` varchar(255) NOT NULL,
        PRIMARY KEY (`ListenerId`))
    ENGINE=InnoDB
    """
    
    db_cursor.execute(sql)

    
def create_tests_table(db_cursor):
    sql = """
    CREATE TABLE `Tests` (
        `TestId` int(11) NOT NULL AUTO_INCREMENT,
        `ListenerId` int(11) NOT NULL,
        `Others` int(11) NULL,
        
        PRIMARY KEY (`TestId`))
    ENGINE=InnoDB
    """
    
    db_cursor.execute(sql)
    
    
def create_tests_table_index(db_cursor):
    sql = """
    CREATE TABLE `Tests` (
        `TestId` int(11) NOT NULL AUTO_INCREMENT,
        `ListenerId` int(11) NOT NULL,
        `Others` int(11) NULL,
        
        PRIMARY KEY (`TestId`),
        
        FOREIGN KEY (ListenerId)
          REFERENCES Listeners(ListenerId)
            ON UPDATE CASCADE 
            ON DELETE CASCADE
        )
    ENGINE=InnoDB
    """
    
    db_cursor.execute(sql)
    
    
def create_listeners_table_index(db_cursor):
    sql = """
    CREATE TABLE `Listeners` (
        `ListenerId` int(11) NOT NULL AUTO_INCREMENT,
        `FirstName` varchar(255) NOT NULL,
        `LastName` varchar(255) NOT NULL,
        PRIMARY KEY (`ListenerId`),
        INDEX names USING BTREE (`FirstName`))
    ENGINE=InnoDB
    """
    
    db_cursor.execute(sql)
    

def drop_test(db_cursor):
    sql = """
    DROP TABLE tests
    """
    db_cursor.execute(sql)
    

def drop_listeners(db_cursor):
    sql = """
    DROP TABLE listeners
    """
    db_cursor.execute(sql)
    
    
def insert_tests_table(db_cursor):
    np.random.seed(0xCAFFE)
    random_listeners_id = np.random.randint(low=1, high=NUMBER_OF_GENERATED_SAMPLES, 
                                            size=(NUMBER_OF_GENERATED_SAMPLES, ))

    random_other = np.random.randint(low=1, high=NUMBER_OF_GENERATED_SAMPLES, 
                                     size=(NUMBER_OF_GENERATED_SAMPLES, ))
    
    data = np.hstack((random_listeners_id.reshape(-1, 1),
                      random_other.reshape(-1, 1)))
    
    sql = """
    INSERT INTO tests (ListenerId, Others)
    VALUES (%s, %s)
    """
    
    for row_index in tqdm(range(NUMBER_OF_GENERATED_SAMPLES)):
        first, second = data[row_index]
        db_cursor.execute(sql, (str(first), str(second)))
        

def insert_listeners_table(db_cursor):
    np.random.seed(0xCAFFE)
    first_names = np.array(['aaa', 'bbb', 'ccc'])
    second_names = np.array(['ddd', 'eee', 'ggg', 'jjj'])
    
    random_indexes_first = np.random.randint(low=0, high=first_names.shape[0], 
                                             size=(NUMBER_OF_GENERATED_SAMPLES, ))

    random_indexes_second = np.random.randint(low=0, high=second_names.shape[0], 
                                              size=(NUMBER_OF_GENERATED_SAMPLES, ))
    
    data = np.hstack((first_names[random_indexes_first].reshape(-1, 1),
                      second_names[random_indexes_second].reshape(-1, 1)))
    
    sql = """
    INSERT INTO listeners (FirstName, LastName)
    VALUES (%s, %s)
    """
    
    for row_index in tqdm(range(NUMBER_OF_GENERATED_SAMPLES)):
        first_name, second_name = data[row_index]
        db_cursor.execute(sql, (str(first_name), str(second_name)))
        
        
def select_with_join_and_where(db_cursor):
    sql = """
    SELECT * 
    FROM listeners as L
    LEFT JOIN tests as T
         ON T.ListenerId = L.ListenerId
    WHERE FirstName like 'aaa'
    """
    current_time = time()
    db_cursor.execute(sql)
    for _ in db_cursor:
        pass
    print('Time elapsed: %s sec' % (time() - current_time))
    
    
def main():
    
    operation_list = [
        ('Create listeners table', create_listeners_table),
        ('Create tests table', create_tests_table),
        ('Inserting %d elements to listeners table' % NUMBER_OF_GENERATED_SAMPLES, insert_listeners_table),
        ('Inserting %d elements to tests table' % NUMBER_OF_GENERATED_SAMPLES, insert_tests_table),
        ('Selecting', select_with_join_and_where),
        ('Droping test', drop_test),
        ('Droping listeners', drop_listeners),
        ('Create listeners table with index', create_listeners_table_index),
        ('Create tests table with index', create_tests_table_index),
        ('Inserting %d elements to listeners table' % NUMBER_OF_GENERATED_SAMPLES, insert_listeners_table),
        ('Inserting %d elements to tests table' % NUMBER_OF_GENERATED_SAMPLES, insert_tests_table),
        ('Selecting', select_with_join_and_where),
        ('Droping test', drop_test),
        ('Droping listeners', drop_listeners),
    ]

    connection = mysql.connector.connect(user='ALEXKIRNAS', 
                                         password='1234',
                                         host='127.0.0.1',
                                         database='database')
    db_cursor = connection.cursor()
    
    for name, function in operation_list:
        print(name, end=':\n')
        function(db_cursor)
        connection.commit()
        print("Finished")
        
    db_cursor.close()    
    connection.close()
    
if __name__ == '__main__':
    main()