students = LOAD '/Users/chang/Documents/Software/Languages/hadoop/ucsc/pig/ucsc-data/studenttab10k' AS (name: chararray, age: int, gpa: float);
student_group = group students all;
student_count = foreach student_group generate 'student count is', COUNT(students);
dump student_count;

