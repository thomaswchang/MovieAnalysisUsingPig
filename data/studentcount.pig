students = load './data/student/studenttab10k' as (name: chararray, age: int, gpa: float); 
student_group = group students all;
student_count = foreach student_group generate 'student count is', COUNT(students);
dump student_count;
