
-- -----------------------------------------------------
-- Table CSE132B.student
-- -----------------------------------------------------
CREATE TABLE student (
  idstudent SERIAL PRIMARY KEY,
  first_name text NOT NULL,
  last_name text NOT NULL,
  middle_name text,
  ss_num text NOT NULL UNIQUE,
  enrolled boolean NOT NULL,
  residency text NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.previousdegree
-- -----------------------------------------------------
CREATE TABLE previousdegree (
  idpreviousdegree SERIAL PRIMARY KEY,
  type text NOT NULL,
  field text NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.school
-- -----------------------------------------------------
CREATE TABLE school (
  idschool SERIAL PRIMARY KEY,
  name text NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.student_degree_school
-- -----------------------------------------------------
CREATE TABLE student_degree_school (
  idstudent_degree_school SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE,
  idpreviousdegree integer REFERENCES previousdegree(idpreviousdegree) ON DELETE CASCADE ON UPDATE CASCADE,
  idschool integer REFERENCES  school(idschool) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.undergraduate
-- -----------------------------------------------------
CREATE TABLE undergraduate (
  idundergraduate SERIAL PRIMARY KEY,
  college text NOT NULL,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.ms
-- -----------------------------------------------------
CREATE TABLE ms (
  idms SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.undergraduate_ms
-- -----------------------------------------------------
CREATE TABLE undergraduate_ms (
  idundergraduate_ms SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE,
  idms integer REFERENCES ms(idms) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.degree
-- -----------------------------------------------------
CREATE TABLE degree (
  iddegree SERIAL PRIMARY KEY,
  total_units text NOT NULL,
  name text NOT NULL,
  type text NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.lower_division
-- -----------------------------------------------------
CREATE TABLE lower_division (
  idlower_division SERIAL PRIMARY KEY,
  iddegree integer REFERENCES degree(iddegree) ON DELETE CASCADE ON UPDATE CASCADE,
  units integer NOT NULL,
  gpa double precision NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.upper_division
-- -----------------------------------------------------
CREATE TABLE upper_division (
  idlower_division SERIAL PRIMARY KEY,
  iddegree integer REFERENCES degree(iddegree) ON DELETE CASCADE ON UPDATE CASCADE,
  units integer NOT NULL,
  gpa double precision NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.minimum_gpa
-- -----------------------------------------------------
CREATE TABLE minimum_gpa (
  idminimum_gpa SERIAL PRIMARY KEY,
  gpa double precision NOT NULL,
  iddegree integer REFERENCES degree(iddegree) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.concentration
-- -----------------------------------------------------
CREATE TABLE concentration (
  idconcentration SERIAL PRIMARY KEY,
  iddegree integer REFERENCES degree(iddegree) ON DELETE CASCADE ON UPDATE CASCADE,
  gpa double precision NOT NULL,
  name text NOT NULL UNIQUE
  );


-- -----------------------------------------------------
-- Table CSE132B.department
-- -----------------------------------------------------
CREATE TABLE department (
  iddepartment SERIAL PRIMARY KEY,
  name text NOT NULL UNIQUE,
  abbr text NOT NULL UNIQUE
  );


-- -----------------------------------------------------
-- Table CSE132B.department_degree
-- -----------------------------------------------------
CREATE TABLE department_degree (
  iddepartment_degree SERIAL PRIMARY KEY,
  iddepartment integer REFERENCES department(iddepartment) ON DELETE CASCADE ON UPDATE CASCADE,
  iddegree integer REFERENCES degree(iddegree) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.graduate_degree
-- -----------------------------------------------------
CREATE TABLE graduate_degree (
  idgraduate_degree SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE,
  iddegree integer REFERENCES degree(iddegree) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.graduate_department
-- -----------------------------------------------------
CREATE TABLE graduate_department (
  idgraduate_department SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE,
  iddepartment integer REFERENCES department(iddepartment) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.undergraduate_degree__major
-- -----------------------------------------------------
CREATE TABLE undergraduate_degree__major (
  idundergraduate_degree__major SERIAL PRIMARY KEY,
  idundergraduate integer REFERENCES undergraduate(idundergraduate) ON DELETE CASCADE ON UPDATE CASCADE,
  iddegree integer REFERENCES degree(iddegree) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.undergraduate_degree__minor
-- -----------------------------------------------------
CREATE TABLE undergraduate_degree__minor (
  idundergraduate_degree__minor SERIAL PRIMARY KEY,
  idundergraduate integer REFERENCES undergraduate(idundergraduate) ON DELETE CASCADE ON UPDATE CASCADE,
  iddegree integer REFERENCES degree(iddegree) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty
-- -----------------------------------------------------
CREATE TABLE faculty (
  faculty_name text NOT NULL UNIQUE PRIMARY KEY,
  title text NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.department_faculty
-- -----------------------------------------------------
CREATE TABLE department_faculty (
  iddepartment_faculty SERIAL PRIMARY KEY,
  iddepartment integer REFERENCES department(iddepartment) ON DELETE CASCADE ON UPDATE CASCADE,
  faculty_name text REFERENCES faculty(faculty_name) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.candidate
-- -----------------------------------------------------
CREATE TABLE candidate (
  idcandidate SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.precandidate
-- -----------------------------------------------------
CREATE TABLE precandidate (
  idprecandidate SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty_candidate
-- -----------------------------------------------------
CREATE TABLE faculty_candidate (
  idfaculty_candidate SERIAL PRIMARY KEY,
  faculty_name text REFERENCES faculty(faculty_name) ON DELETE CASCADE ON UPDATE CASCADE,
  idcandidate integer REFERENCES candidate(idcandidate) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty_graduate__dept
-- -----------------------------------------------------
CREATE TABLE faculty_graduate__dept (
  idfaculty_graduate__dept SERIAL PRIMARY KEY,
  faculty_name text REFERENCES faculty(faculty_name) ON DELETE CASCADE ON UPDATE CASCADE,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty_graduate__nondept
-- -----------------------------------------------------
CREATE TABLE faculty_graduate__nondept (
  idfaculty_graduate__dept SERIAL PRIMARY KEY,
  faculty_name text REFERENCES faculty(faculty_name) ON DELETE CASCADE ON UPDATE CASCADE,
  idcandidate integer REFERENCES candidate(idcandidate) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.ap
-- -----------------------------------------------------
CREATE TABLE ap (
  idap SERIAL PRIMARY KEY,
  name text NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.student_ap
-- -----------------------------------------------------
CREATE TABLE student_ap (
  idstudent_ap SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE,
  idap integer REFERENCES ap(idap) ON DELETE CASCADE ON UPDATE CASCADE,
  score integer NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.quarter
-- -----------------------------------------------------
CREATE TABLE quarter (
  idquarter SERIAL PRIMARY KEY,
  year integer NOT NULL,
  season text NOT NULL
  );

INSERT INTO quarter (year, season) VALUES(2009, 'Winter');
INSERT INTO quarter (year, season) VALUES(2009, 'Spring');
INSERT INTO quarter (year, season) VALUES(2009, 'Summer');
INSERT INTO quarter (year, season) VALUES(2009, 'Fall');

INSERT INTO quarter (year, season) VALUES(2010, 'Winter');
INSERT INTO quarter (year, season) VALUES(2010, 'Spring');
INSERT INTO quarter (year, season) VALUES(2010, 'Summer');
INSERT INTO quarter (year, season) VALUES(2010, 'Fall');

INSERT INTO quarter (year, season) VALUES(2011, 'Winter');
INSERT INTO quarter (year, season) VALUES(2011, 'Spring');
INSERT INTO quarter (year, season) VALUES(2011, 'Summer');
INSERT INTO quarter (year, season) VALUES(2011, 'Fall');

INSERT INTO quarter (year, season) VALUES(2012, 'Winter');
INSERT INTO quarter (year, season) VALUES(2012, 'Spring');
INSERT INTO quarter (year, season) VALUES(2012, 'Summer');
INSERT INTO quarter (year, season) VALUES(2012, 'Fall');

INSERT INTO quarter (year, season) VALUES(2013, 'Winter');
INSERT INTO quarter (year, season) VALUES(2013, 'Spring');
INSERT INTO quarter (year, season) VALUES(2013, 'Summer');
INSERT INTO quarter (year, season) VALUES(2013, 'Fall');

INSERT INTO quarter (year, season) VALUES(2014, 'Winter');
INSERT INTO quarter (year, season) VALUES(2014, 'Spring');
INSERT INTO quarter (year, season) VALUES(2014, 'Summer');
INSERT INTO quarter (year, season) VALUES(2014, 'Fall');

INSERT INTO quarter (year, season) VALUES(2015, 'Winter');
INSERT INTO quarter (year, season) VALUES(2015, 'Spring');
INSERT INTO quarter (year, season) VALUES(2015, 'Summer');
INSERT INTO quarter (year, season) VALUES(2015, 'Fall');

INSERT INTO quarter (year, season) VALUES(2016, 'Winter');
INSERT INTO quarter (year, season) VALUES(2016, 'Spring');
INSERT INTO quarter (year, season) VALUES(2016, 'Summer');
INSERT INTO quarter (year, season) VALUES(2016, 'Fall');


-- -----------------------------------------------------
-- Table CSE132B.student_quarter__attends
-- -----------------------------------------------------
CREATE TABLE student_quarter__attends (
  idstudent_quarter__attends SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE,
  idquarter integer REFERENCES quarter(idquarter) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.student_quarter__probation
-- -----------------------------------------------------
CREATE TABLE student_quarter__probation (
  idstudent_quarter__probation SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE,
  idquarter integer REFERENCES quarter(idquarter) ON DELETE CASCADE ON UPDATE CASCADE,
  reason text NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.class
-- -----------------------------------------------------
CREATE TABLE class (
  idclass SERIAL PRIMARY KEY,
  title text NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.student_pastclass
-- -----------------------------------------------------
CREATE TABLE student_pastclass (
  idstudent_pastclass SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE,
  idclass integer REFERENCES class(idclass) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.course
-- -----------------------------------------------------
CREATE TABLE course (
  idcourse SERIAL PRIMARY KEY,
  grade_option_type text NOT NULL,
  min_units integer NOT NULL,
  max_units integer NOT NULL,
  lab boolean NOT NULL,
  consent_prereq boolean NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.coursenumber
-- -----------------------------------------------------
CREATE TABLE coursenumber (
  idcoursenumber SERIAL PRIMARY KEY,
  number text NOT NULL UNIQUE
  );


-- -----------------------------------------------------
-- Table CSE132B.course_coursenumber
-- -----------------------------------------------------
CREATE TABLE course_coursenumber (
  idcourse_coursenumber SERIAL PRIMARY KEY,
  idcourse integer REFERENCES course(idcourse) ON DELETE CASCADE ON UPDATE CASCADE,
  idcoursenumber integer REFERENCES coursenumber(idcoursenumber) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.department_course
-- -----------------------------------------------------
CREATE TABLE department_course (
  iddepartment_course SERIAL PRIMARY KEY,
  iddepartment integer REFERENCES department(iddepartment) ON DELETE CASCADE ON UPDATE CASCADE,
  idcourse integer REFERENCES course(idcourse) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.concentration_course
-- -----------------------------------------------------
CREATE TABLE concentration_course (
  idconcentration_course SERIAL PRIMARY KEY,
  idconcentration integer REFERENCES concentration(idconcentration) ON DELETE CASCADE ON UPDATE CASCADE,
  idcourse integer REFERENCES course(idcourse) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.prereqs
-- -----------------------------------------------------
CREATE TABLE prereqs (
  idprereqs SERIAL PRIMARY KEY,
  idcourse integer REFERENCES course(idcourse) ON DELETE CASCADE ON UPDATE CASCADE,
  prereq_idcourse integer REFERENCES course(idcourse) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.quarter_course_class__instance
-- -----------------------------------------------------
CREATE TABLE quarter_course_class__instance (
  idinstance SERIAL PRIMARY KEY,
  idquarter integer REFERENCES quarter(idquarter) ON DELETE CASCADE ON UPDATE CASCADE,
  idcourse integer REFERENCES course(idcourse) ON DELETE CASCADE ON UPDATE CASCADE,
  idclass integer REFERENCES class(idclass) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.student_instance
-- -----------------------------------------------------
CREATE TABLE student_instance (
  idstudent_instance SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE,
  idinstance integer REFERENCES quarter_course_class__instance(idinstance) ON DELETE CASCADE ON UPDATE CASCADE,
  units integer NOT NULL,
  grade_option_type text NOT NULL,
  grade text NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.section
-- -----------------------------------------------------
CREATE TABLE section (
  idsection SERIAL PRIMARY KEY,
  enrollment_limit integer NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.instance_section
-- -----------------------------------------------------
CREATE TABLE instance_section (
  idinstance_section SERIAL PRIMARY KEY,
  idinstance integer REFERENCES quarter_course_class__instance(idinstance) ON DELETE CASCADE ON UPDATE CASCADE,
  idsection integer REFERENCES section(idsection) ON DELETE CASCADE ON UPDATE CASCADE
  );
  
  

-- -----------------------------------------------------
-- Table CSE132B.faculty_class_section
-- -----------------------------------------------------
CREATE TABLE faculty_class_section (
  idfaculty_class SERIAL PRIMARY KEY,
  faculty_name text REFERENCES faculty(faculty_name) ON DELETE CASCADE ON UPDATE CASCADE,
  idclass integer REFERENCES class(idclass) ON DELETE CASCADE ON UPDATE CASCADE,
  idsection integer REFERENCES section(idsection) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty_instance_teaches
-- -----------------------------------------------------
CREATE TABLE faculty_instance_teaches (
  idfaculty_instance_teaches SERIAL PRIMARY KEY,
  faculty_name text REFERENCES faculty(faculty_name) ON DELETE CASCADE ON UPDATE CASCADE,
  idinstance integer REFERENCES quarter_course_class__instance(idinstance) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty_instance_willteach
-- -----------------------------------------------------
CREATE TABLE faculty_instance_willteach (
  idfaculty_instance_willteach SERIAL PRIMARY KEY,
  faculty_name text REFERENCES faculty(faculty_name) ON DELETE CASCADE ON UPDATE CASCADE,
  idinstance integer REFERENCES quarter_course_class__instance(idinstance) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty_instance_hastaught
-- -----------------------------------------------------
CREATE TABLE faculty_instance_hastaught (
  idfaculty_instance_hastaught SERIAL PRIMARY KEY,
  faculty_name text REFERENCES faculty(faculty_name) ON DELETE CASCADE ON UPDATE CASCADE,
  idinstance integer REFERENCES quarter_course_class__instance(idinstance) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.student_section__enrolled
-- -----------------------------------------------------
CREATE TABLE student_section__enrolled (
  idstudent_section__enrolled SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE,
  idsection integer REFERENCES section(idsection) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.student_section__waitlist
-- -----------------------------------------------------
CREATE TABLE student_section__waitlist (
  idstudent_section__waitlist SERIAL PRIMARY KEY,
  idstudent integer REFERENCES student(idstudent) ON DELETE CASCADE ON UPDATE CASCADE,
  idsection integer REFERENCES section(idsection) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.weekly
-- -----------------------------------------------------
CREATE TABLE weekly (
  idweekly SERIAL PRIMARY KEY,
  building text NOT NULL,
  room text NOT NULL,
  day_of_week text NOT NULL,
  start_time time without time zone NOT NULL,
  end_time time without time zone NOT NULL,
  type text NOT NULL
  );


-- -----------------------------------------------------
-- Table CSE132B.reviewsession
-- -----------------------------------------------------
CREATE TABLE reviewsession (
  idreviewsession SERIAL PRIMARY KEY,
  "time" DATE NOT NULL,
  start_time time without time zone NOT NULL,
  end_time time without time zone NOT NULL,
  building text NOT NULL,
  room text NOT NULL
  );



-- -----------------------------------------------------
-- Table CSE132B.section_weekly
-- -----------------------------------------------------
CREATE TABLE section_weekly (
  idsection_weekly SERIAL PRIMARY KEY,
  idsection integer REFERENCES section(idsection) ON DELETE CASCADE ON UPDATE CASCADE,
  idweekly integer REFERENCES weekly(idweekly) ON DELETE CASCADE ON UPDATE CASCADE
  );


-- -----------------------------------------------------
-- Table CSE132B.section_reviewsession
-- -----------------------------------------------------
CREATE TABLE section_reviewsession (
  idsection_reviewsession SERIAL PRIMARY KEY,
  idsection integer REFERENCES section(idsection) ON DELETE CASCADE ON UPDATE CASCADE,
  idreviewsession integer REFERENCES reviewsession(idreviewsession) ON DELETE CASCADE ON UPDATE CASCADE
  );

-- -----------------------------------------------------
-- Table CSE132B.GRADE_CONVERSION
-- -----------------------------------------------------
create table grade_conversion ( 
	grade CHAR(2) NOT NULL,
	number_grade DECIMAL(2,1)
	);
insert into grade_conversion values('A+', 4.3);
insert into grade_conversion values('A', 4);
insert into grade_conversion values('A-', 3.7);
insert into grade_conversion values('B+', 3.4);
insert into grade_conversion values('B', 3.1);
insert into grade_conversion values('B-', 2.8);
insert into grade_conversion values('C+', 2.5);
insert into grade_conversion values('C', 2.2);
insert into grade_conversion values('C-', 1.9);
insert into grade_conversion values('D', 1.6);