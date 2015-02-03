
-- -----------------------------------------------------
-- Table CSE132B.student
-- -----------------------------------------------------
CREATE TABLE student (
  idstudent integer NOT NULL,
  first_name text NOT NULL,
  last_name text NOT NULL,
  middle_name text NOT NULL,
  ss_num text NOT NULL,
  enrolled bit NOT NULL,
  residency text NOT NULL,
  primary key (idstudent) 
  );


-- -----------------------------------------------------
-- Table CSE132B.previousdegree
-- -----------------------------------------------------
CREATE TABLE previousdegree (
  idpreviousdegree integer NOT NULL,
  type text NOT NULL,
  field text NOT NULL,
  primary key (idpreviousdegree)
  );


-- -----------------------------------------------------
-- Table CSE132B.school
-- -----------------------------------------------------
CREATE TABLE school (
  idschool integer NOT NULL,
  name text NOT NULL,
  primary key (idschool)
  );


-- -----------------------------------------------------
-- Table CSE132B.student_degree_school
-- -----------------------------------------------------
CREATE TABLE student_degree_school (
  idstudent_degree_school integer NOT NULL,
  idstudent integer NOT NULL,
  idpreviousdegree integer NOT NULL,
  idschool integer NOT NULL,
  primary key (idstudent_degree_school),
  foreign key (idschool) references school,
  foreign key (idpreviousdegree) references previousdegree,
  foreign key (idstudent) references student
  );


-- -----------------------------------------------------
-- Table CSE132B.undergraduate
-- -----------------------------------------------------
CREATE TABLE undergraduate (
  idundergraduate integer NOT NULL,
  college text NOT NULL,
  idstudent integer NOT NULL,
  primary key (idundergraduate),
  foreign key (idstudent) references student
  );


-- -----------------------------------------------------
-- Table CSE132B.ms
-- -----------------------------------------------------
CREATE TABLE ms (
  idms integer NOT NULL,
  idstudent integer NOT NULL,
  primary key (idms),
  foreign key (idstudent) references student
  );


-- -----------------------------------------------------
-- Table CSE132B.undergraduate_ms
-- -----------------------------------------------------
CREATE TABLE undergraduate_ms (
  idundergraduate_ms integer NOT NULL,
  idundergraduate integer NOT NULL,
  idms integer NOT NULL,
  primary key (idundergraduate_ms),
  foreign key (idundergraduate) references undergraduate,
  foreign key (idms) references ms
  );


-- -----------------------------------------------------
-- Table CSE132B.degree
-- -----------------------------------------------------
CREATE TABLE degree (
  iddegree integer NOT NULL,
  total_units text NOT NULL,
  name text NOT NULL,
  type text NOT NULL,
  primary key (iddegree)
  );


-- -----------------------------------------------------
-- Table CSE132B.lower_division
-- -----------------------------------------------------
CREATE TABLE lower_division (
  idlower_division integer NOT NULL,
  iddegree integer NOT NULL,
  units integer NOT NULL,
  gpa double precision NOT NULL,
  primary key (idlower_division),
  foreign key (iddegree) references degree
  );


-- -----------------------------------------------------
-- Table CSE132B.upper_division
-- -----------------------------------------------------
CREATE TABLE upper_division (
  idlower_division integer NOT NULL,
  iddegree integer NOT NULL,
  units integer NOT NULL,
  gpa double precision NOT NULL,
  primary key (idlower_division),
  foreign key (iddegree) references degree
  );


-- -----------------------------------------------------
-- Table CSE132B.minimum_gpa
-- -----------------------------------------------------
CREATE TABLE minimum_gpa (
  idminimum_gpa integer NOT NULL,
  gpa double precision NOT NULL,
  iddegree integer NOT NULL,
  primary key (idminimum_gpa),
  foreign key (iddegree) references degree
  );


-- -----------------------------------------------------
-- Table CSE132B.concentration
-- -----------------------------------------------------
CREATE TABLE concentration (
  idconcentration integer NOT NULL,
  iddegree integer NOT NULL,
  gpa double precision NOT NULL,
  primary key (idconcentration),
  foreign key (iddegree) references degree
  );


-- -----------------------------------------------------
-- Table CSE132B.department
-- -----------------------------------------------------
CREATE TABLE department (
  iddepartment integer NOT NULL,
  name text NOT NULL,
  primary key (iddepartment)
  );


-- -----------------------------------------------------
-- Table CSE132B.department_degree
-- -----------------------------------------------------
CREATE TABLE department_degree (
  iddepartment_degree integer NOT NULL,
  iddepartment integer NOT NULL,
  iddegree integer NOT NULL,
  primary key (iddepartment_degree),
  foreign key (iddepartment) references department,
  foreign key (iddegree) references degree
  );


-- -----------------------------------------------------
-- Table CSE132B.graduate_degree
-- -----------------------------------------------------
CREATE TABLE graduate_degree (
  idgraduate_degree integer NOT NULL,
  idstudent integer NOT NULL,
  iddegree integer NOT NULL,
  primary key (idgraduate_degree),
  foreign key (idstudent) references student,
  foreign key (iddegree) references degree
  );


-- -----------------------------------------------------
-- Table CSE132B.graduate_department
-- -----------------------------------------------------
CREATE TABLE graduate_department (
  idgraduate_department integer NOT NULL,
  idstudent integer NOT NULL,
  iddepartment integer NOT NULL,
  primary key (idgraduate_department),
  foreign key (idstudent) references student,
  foreign key (iddepartment) references department
  );


-- -----------------------------------------------------
-- Table CSE132B.undergraduate_degree__major
-- -----------------------------------------------------
CREATE TABLE undergraduate_degree__major (
  idundergraduate_degree__major integer NOT NULL,
  idundergraduate integer NOT NULL,
  iddegree integer NOT NULL,
  primary key (idundergraduate_degree__major),
  foreign key (idundergraduate) references undergraduate,
  foreign key (iddegree) references degree
  );


-- -----------------------------------------------------
-- Table CSE132B.undergraduate_degree__minor
-- -----------------------------------------------------
CREATE TABLE undergraduate_degree__minor (
  idundergraduate_degree__major integer NOT NULL,
  idundergraduate integer NOT NULL,
  iddegree integer NOT NULL,
  primary key (idundergraduate_degree__major),
  foreign key (idundergraduate) references undergraduate,
  foreign key (iddegree) references degree
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty
-- -----------------------------------------------------
CREATE TABLE faculty (
  name text NOT NULL,
  title text NOT NULL,
  primary key (name)
  );


-- -----------------------------------------------------
-- Table CSE132B.department_faculty
-- -----------------------------------------------------
CREATE TABLE department_faculty (
  iddepartment_faculty integer NOT NULL,
  iddepartment integer NOT NULL,
  faculty_name text NOT NULL,
  primary key (iddepartment_faculty),
  foreign key (iddepartment) references department,
  foreign key (faculty_name) references faculty
  );


-- -----------------------------------------------------
-- Table CSE132B.candidate
-- -----------------------------------------------------
CREATE TABLE candidate (
  idcandidate integer NOT NULL,
  idstudent integer NOT NULL,
  primary key (idcandidate),
  foreign key (idstudent) references student
  );


-- -----------------------------------------------------
-- Table CSE132B.precandidate
-- -----------------------------------------------------
CREATE TABLE precandidate (
  idcandidate integer NOT NULL,
  idstudent integer NOT NULL,
  primary key (idcandidate),
  foreign key (idstudent) references student
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty_candidate
-- -----------------------------------------------------
CREATE TABLE faculty_candidate (
  idfaculty_candidate integer NOT NULL,
  faculty_name text NOT NULL,
  idcandidate integer NOT NULL,
  primary key (idfaculty_candidate),
  foreign key (faculty_name) references faculty,
  foreign key (idcandidate) references candidate
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty_graduate__dept
-- -----------------------------------------------------
CREATE TABLE faculty_graduate__dept (
  idfaculty_graduate__dept integer NOT NULL,
  faculty_name text NOT NULL,
  idstudent integer NOT NULL,
  primary key (idfaculty_graduate__dept),
  foreign key (faculty_name) references faculty,
  foreign key (idstudent) references student
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty_graduate__nondept
-- -----------------------------------------------------
CREATE TABLE faculty_graduate__nondept (
  idfaculty_graduate__dept integer NOT NULL,
  faculty_name text NOT NULL,
  idcandidate integer NOT NULL,
  primary key (idfaculty_graduate__dept),
  foreign key (faculty_name) references faculty,
  foreign key (idcandidate) references candidate

  );


-- -----------------------------------------------------
-- Table CSE132B.ap
-- -----------------------------------------------------
CREATE TABLE ap (
  idap integer NOT NULL,
  name text NOT NULL,
  primary key (idap)
  );


-- -----------------------------------------------------
-- Table CSE132B.student_ap
-- -----------------------------------------------------
CREATE TABLE student_ap (
  idstudent_ap integer NOT NULL,
  idstudent integer NOT NULL,
  idap integer NOT NULL,
  score integer NOT NULL,
  primary key (idstudent_ap),
  foreign key (idstudent) references student,
  foreign key (idap) references ap
  );


-- -----------------------------------------------------
-- Table CSE132B.quarter
-- -----------------------------------------------------
CREATE TABLE quarter (
  idquarter integer NOT NULL,
  year integer NOT NULL,
  season text NOT NULL,
  primary key (idquarter)
  );


-- -----------------------------------------------------
-- Table CSE132B.student_quarter__attends
-- -----------------------------------------------------
CREATE TABLE student_quarter__attends (
  idstudent_quarter_attends integer NOT NULL,
  idstudent integer NOT NULL,
  idquarter integer NOT NULL,
  primary key (idstudent_quarter_attends),
  foreign key (idstudent) references student,
  foreign key (idquarter) references quarter
  );


-- -----------------------------------------------------
-- Table CSE132B.student_quarter__probation
-- -----------------------------------------------------
CREATE TABLE student_quarter__probation (
  idstudent_quarter__probation integer NOT NULL,
  idstudent integer NOT NULL,
  idquarter integer NOT NULL,
  reason text NOT NULL,
  primary key (idstudent_quarter__probation),
  foreign key (idstudent) references student,
  foreign key (idquarter) references quarter
  );


-- -----------------------------------------------------
-- Table CSE132B.class
-- -----------------------------------------------------
CREATE TABLE class (
  idclass integer NOT NULL,
  title text NOT NULL,
  primary key (idclass)
  );


-- -----------------------------------------------------
-- Table CSE132B.course
-- -----------------------------------------------------
CREATE TABLE course (
  idcourse integer NOT NULL,
  grade_option_type text NOT NULL,
  lab bit NOT NULL,
  consent_prereq bit NOT NULL,
  primary key (idcourse)
  );


-- -----------------------------------------------------
-- Table CSE132B.coursenumber
-- -----------------------------------------------------
CREATE TABLE coursenumber (
  idcoursenumber integer NOT NULL,
  number text NOT NULL,
  primary key (idcoursenumber)
  );


-- -----------------------------------------------------
-- Table CSE132B.course_coursenumber
-- -----------------------------------------------------
CREATE TABLE course_coursenumber (
  idcourse_coursenumber integer NOT NULL,
  idcourse integer NOT NULL,
  idcoursenumber integer NOT NULL,
  primary key (idcourse_coursenumber),
  foreign key (idcourse) references course,
  foreign key (idcoursenumber) references coursenumber
  );


-- -----------------------------------------------------
-- Table CSE132B.units
-- -----------------------------------------------------
CREATE TABLE units (
  idunits integer NOT NULL,
  min integer NOT NULL,
  max integer NOT NULL,
  primary key (idunits)
  );


-- -----------------------------------------------------
-- Table CSE132B.course_units
-- -----------------------------------------------------
CREATE TABLE course_units (
  idcourse_units integer NOT NULL,
  idcourse integer NOT NULL,
  idunits integer NOT NULL,
  primary key (idcourse_units),
  foreign key (idcourse) references course,
  foreign key (idunits) references units
  );


-- -----------------------------------------------------
-- Table CSE132B.department_course
-- -----------------------------------------------------
CREATE TABLE department_course (
  iddepartment_course integer NOT NULL,
  iddepartment integer NOT NULL,
  idcourse integer NOT NULL,
  primary key (iddepartment_course)
  );


-- -----------------------------------------------------
-- Table CSE132B.concentration_course
-- -----------------------------------------------------
CREATE TABLE concentration_course (
  idconcentration_course integer NOT NULL,
  idconcentration integer NOT NULL,
  idcourse integer NOT NULL,
  primary key (idconcentration_course),
  foreign key (idconcentration) references concentration,
  foreign key (idcourse) references course
  );


-- -----------------------------------------------------
-- Table CSE132B.prereqs
-- -----------------------------------------------------
CREATE TABLE prereqs (
  idprereqs integer NOT NULL,
  idcourse integer NOT NULL,
  prereq_idcourse integer NOT NULL,
  primary key (idprereqs),
  foreign key (idcourse) references course,
  foreign key (prereq_idcourse) references course
  );


-- -----------------------------------------------------
-- Table CSE132B.quarter_course_class__instance
-- -----------------------------------------------------
CREATE TABLE quarter_course_class__instance (
  idinstance integer NOT NULL,
  idquarter integer NOT NULL,
  idcourse integer NOT NULL,
  idclass integer NOT NULL,
  primary key (idinstance),
  foreign key (idquarter) references quarter,
  foreign key (idcourse) references course,
  foreign key (idclass) references class
  );


-- -----------------------------------------------------
-- Table CSE132B.student_instance
-- -----------------------------------------------------
CREATE TABLE student_instance (
  idstudent_instance integer NOT NULL,
  idstudent integer NOT NULL,
  idinstance integer NOT NULL,
  grade text NOT NULL,
  primary key (idstudent_instance),
  foreign key (idstudent) references student,
  foreign key (idinstance) references quarter_course_class__instance
  );


-- -----------------------------------------------------
-- Table CSE132B.section
-- -----------------------------------------------------
CREATE TABLE section (
  idsection integer NOT NULL,
  enrollment_limit integer NOT NULL,
  primary key (idsection)
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty_class_section
-- -----------------------------------------------------
CREATE TABLE faculty_class_section (
  idfaculty_class integer NOT NULL,
  faculty_name text NOT NULL,
  idclass integer NOT NULL,
  idsection integer NOT NULL,
  primary key (idfaculty_class),
  foreign key (faculty_name) references faculty,
  foreign key (idclass) references class,
  foreign key (idsection) references section
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty_instance_teaches
-- -----------------------------------------------------
CREATE TABLE faculty_instance_teaches (
  idfaculty_instance_hastaught integer NOT NULL,
  faculty_name text NOT NULL,
  idinstance integer NOT NULL,
  primary key (idfaculty_instance_hastaught),
  foreign key (faculty_name) references faculty,
  foreign key (idinstance) references quarter_course_class__instance
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty_instance_willteach
-- -----------------------------------------------------
CREATE TABLE faculty_instance_willteach (
  idfaculty_instance_hastaught integer NOT NULL,
  faculty_name text NOT NULL,
  idinstance integer NOT NULL,
  primary key (idfaculty_instance_hastaught),
  foreign key (faculty_name) references faculty,
  foreign key (idinstance) references quarter_course_class__instance
  );


-- -----------------------------------------------------
-- Table CSE132B.faculty_instance_hastaught
-- -----------------------------------------------------
CREATE TABLE faculty_instance_hastaught (
  idfaculty_instance_hastaught integer NOT NULL,
  faculty_name text NOT NULL,
  idinstance integer NOT NULL,
  primary key (idfaculty_instance_hastaught),
  foreign key (faculty_name) references faculty,
  foreign key (idinstance) references quarter_course_class__instance
  );


-- -----------------------------------------------------
-- Table CSE132B.student_section__enrolled
-- -----------------------------------------------------
CREATE TABLE student_section__enrolled (
  idstudent_section__enrolled integer NOT NULL,
  idstudent integer NOT NULL,
  idsection integer NOT NULL,
  primary key (idstudent_section__enrolled),
  foreign key (idstudent) references student,
  foreign key (idsection) references section
  );


-- -----------------------------------------------------
-- Table CSE132B.student_section__waitlist
-- -----------------------------------------------------
CREATE TABLE student_section__waitlist (
  idstudent_section__enrolled integer NOT NULL,
  idstudent integer NOT NULL,
  idsection integer NOT NULL,
  primary key (idstudent_section__enrolled),
  foreign key (idstudent) references student,
  foreign key (idsection) references section
  );


-- -----------------------------------------------------
-- Table CSE132B.weekly
-- -----------------------------------------------------
CREATE TABLE weekly (
  idweekly integer NOT NULL,
  building text NOT NULL,
  room text NOT NULL,
  day_of_week text NOT NULL,
  start_time timestamp without time zone NOT NULL,
  end_time timestamp without time zone NOT NULL,
  type text NOT NULL,
  primary key (idweekly)
  );


-- -----------------------------------------------------
-- Table CSE132B.reviewsession
-- -----------------------------------------------------
CREATE TABLE reviewsession (
  idreviewsession integer NOT NULL,
  "time" DATE NOT NULL,
  start_time timestamp without time zone NOT NULL,
  end_time timestamp without time zone NOT NULL,
  building text NOT NULL,
  room text NOT NULL,
  primary key (idreviewsession)
  );



-- -----------------------------------------------------
-- Table CSE132B.section_weekly
-- -----------------------------------------------------
CREATE TABLE section_weekly (
  idsection_weekly integer NOT NULL,
  idsection integer NOT NULL,
  idweekly integer NOT NULL,
  primary key (idsection_weekly),
  foreign key (idsection) references section,
  foreign key (idweekly) references weekly
  );


-- -----------------------------------------------------
-- Table CSE132B.section_reviewsession
-- -----------------------------------------------------
CREATE TABLE section_reviewsession (
  idsection_reviewsession integer NOT NULL,
  idsection integer NOT NULL,
  idreviewsession integer NOT NULL,
  primary key (idsection_reviewsession),
  foreign key (idsection) references section,
  foreign key (idreviewsession) references reviewsession
  );
