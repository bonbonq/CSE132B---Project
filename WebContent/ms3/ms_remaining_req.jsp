<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>MS Req</title>
</head>
</head>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*" %>
<%@page import="org.postgresql.*" %>

<!-- =============== -->
<!-- Java Part Start -->
<!-- =============== -->

<%
boolean debug= true;
/* Create DB connection */
boolean success = false;
Connection conn = null;
String sql1 = "";
String sql2 = "";
String sql3 = "";
String sql4 = "";
String sql5 = "";
PreparedStatement pstmt1 = null;
PreparedStatement pstmt2 = null;
PreparedStatement pstmt3 = null;
PreparedStatement pstmt4 = null;
PreparedStatement pstmt5 = null;
PreparedStatement pstmt6 = null;

try {
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost/CSE132B?");
	
} catch (Exception e) {
	e.printStackTrace();
	out.println("<h1>org.postgresql.Driver Not Found</h1>");
}

String action = request.getParameter("action");

/* ================== */
/* SUBMIT FORM ACTION */
/* ================== */
ResultSet result_rs = null;
ResultSet result_rs_conc = null;
double final_gpa = 0.0;
//HashSet<Integer> taken_courses = new HashSet<Integer>();
Hashtable<Integer, Double> taken_courses = new Hashtable<Integer, Double>();

if (action!=null && action.equals("submit")) {

	//The following will always run regardless of action
	try{
		conn.setAutoCommit(false);
		pstmt1 = conn.prepareStatement(
				"SELECT * FROM student_instance NATURAL JOIN quarter_course_class__instance NATURAL JOIN course_coursenumber NATURAL JOIN coursenumber NATURAL JOIN grade_conversion WHERE idstudent=?",
				ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
		pstmt1.setInt(1, Integer.parseInt(request.getParameter("ss_num")));
		
		// grab all concentrations
		pstmt4 = conn.prepareStatement(
				//"SELECT * FROM concentration NATURAL JOIN concentration_course NATURAL JOIN course NATURAL JOIN course_coursenumber NATURAL JOIN coursenumber",
				"SELECT * FROM concentration NATURAL JOIN concentration_course NATURAL JOIN course NATURAL JOIN course_coursenumber NATURAL JOIN coursenumber LEFT JOIN degree ON concentration.iddegree=degree.iddegree",
				ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
		//pstmt4.setInt(1, Integer.parseInt(request.getParameter("degree_name")));
		
		result_rs = pstmt1.executeQuery();
		result_rs_conc = pstmt4.executeQuery();

		conn.commit();
		conn.setAutoCommit(true);
		
	} catch(SQLException e) {
		conn.rollback();
		e.printStackTrace();
		String message = "Failure: Unable to retrieve dropdown info - " + e.getMessage();
		%>
		<h1><%=message %></h1>
		<%
	}
	int course_count = 0;
	double cumulative_gpa = 0.0;
	if (result_rs!=null) {
  		if (result_rs.isBeforeFirst()) {
			while(result_rs.next()) { 
				String grade = result_rs.getString("grade");
				if (!grade.equals("PENDING")){
					if (!grade.equals("S") && !grade.equals("U")) {
						cumulative_gpa += result_rs.getDouble("number_grade");
						course_count++;
					}
					taken_courses.put(result_rs.getInt("idcourse"), result_rs.getDouble("number_grade"));
				}
			}
		}	
  	}
	final_gpa = cumulative_gpa/course_count;
}

/* =========================== */
/* Generate Form Fields Action */
/* =========================== */

ResultSet form_rs = null;
ResultSet form_rs_degree = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	int current_year = Calendar.getInstance().get(Calendar.YEAR);
	pstmt2 = conn.prepareStatement(
			"SELECT * FROM ms NATURAL JOIN student NATURAL JOIN student_quarter__attends WHERE idquarter=2 AND ms.idstudent=student.idstudent AND student_quarter__attends.idstudent=student.idstudent;",
			ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	pstmt3 = conn.prepareStatement(
			"SELECT * FROM concentration, degree WHERE degree.type='MS' AND concentration.iddegree=degree.iddegree",
			ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	/* The below two statements are not closed, this might cause issues later... */
	form_rs = pstmt2.executeQuery();
	form_rs_degree = pstmt3.executeQuery();

	conn.commit();
	conn.setAutoCommit(true);
	
} catch(SQLException e) {
	conn.rollback();
	e.printStackTrace();
	String message = "Failure: Unable to retrieve dropdown info - " + e.getMessage();
	%>
	<h1><%=message %></h1>
	<%
} 

%>


<!-- =============== -->
<!-- HTML Body Start -->
<!-- =============== -->

<body>
	
	<a href='index.jsp'><button>Home</button></a>
	<h2>Student's Current Class Listing</h2>
	
	<!-- Student Insertion Form -->
	<form action="ms_remaining_req.jsp" method="POST">
		
		<div>
			Student:
			<select name="ss_num">
				<%
				if (form_rs.isBeforeFirst())
				{
					while(form_rs.next()){
						%>
						<option value=<%=form_rs.getString("idstudent")%>> <%=form_rs.getString("first_name")%> <%=form_rs.getString("middle_name").equals("NULL")? " " : form_rs.getString("middle_name")%> <%=form_rs.getString("last_name")%> - <%=form_rs.getString("ss_num")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<div>
			Degree:
			<select name="degree_name">
				<%
				if (form_rs_degree.isBeforeFirst())
				{
					while(form_rs_degree.next()){
						%>
						<option value=<%=form_rs_degree.getString("idconcentration")%>> <%=form_rs_degree.getString(8)%> - <%=form_rs_degree.getString("name")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<button type="submit" name="action" value="submit">Submit</button>
		
	</form>
	<br>
	<br>
	
	<!-- Edit Form -->
	<h2>Cumulative GPA: <%=final_gpa %></h2>
	<%
	String completed_conc = "";
	int prev_conc = 0;
	
	int incomplete_req = 0;
	double conc_gpa_sum = 0.0;
	int conc_course_count = 0;

	double last_gpa = 0.0;
	String last_name = "";
	
	if (result_rs_conc!=null) {
  		if (result_rs_conc.isBeforeFirst()) {
			while(result_rs_conc.next()) {
				
				if (prev_conc==0) {
					prev_conc = result_rs_conc.getInt("idconcentration");
					%> <h2><%=result_rs_conc.getString(17) %> - <%=result_rs_conc.getString("name") %> </h2> <%
				}
				
				// new conc
				if (prev_conc!=result_rs_conc.getInt("idconcentration")) {
					
					//show gpa comparison of prev conc
					double quarter_cum_gpa = conc_gpa_sum/conc_course_count;
					%> <h4>&nbsp;&nbsp;&nbsp;Concentration GPA: <%=quarter_cum_gpa %> </h4> <%
					if (quarter_cum_gpa < result_rs_conc.getDouble("gpa"))
						incomplete_req++;
					
					//determine if conc is completed and add to list
					%> <h4>&nbsp;&nbsp;&nbsp;Incomplete Requirements: <%=incomplete_req %> </h4> <%
					if (incomplete_req==0)
						completed_conc = completed_conc + "," + result_rs_conc.getString("name");
					
					//reset all counters
					incomplete_req = 0;
					conc_gpa_sum = 0.0;
					conc_course_count = 0;
	
					//show concentration name
					prev_conc = result_rs_conc.getInt("idconcentration");
					%> <br><h2><%=result_rs_conc.getString(17) %> - <%=result_rs_conc.getString("name") %> </h2> <%
					
					//compare if conc taken
					// if not taken, then show name and increase incomplete req counter
					
				}
			
				//compare if conc taken
				// if not taken, then show name and increase incomplete req counter
				if (!taken_courses.containsKey(result_rs_conc.getInt("idcourse"))) {
					%> <h4>&nbsp;&nbsp;&nbsp;<%=result_rs_conc.getString("number") %> </h4> <%
					incomplete_req++;
				}
				else {
					conc_gpa_sum += taken_courses.get(result_rs_conc.getInt("idcourse"));
					conc_course_count++;
					
				}
				
				
			}
		}	
  	}
	// final calculations for last concentration
	if (result_rs_conc!=null) {
		result_rs_conc.last();
		//show gpa comparison of prev conc
		double quarter_cum_gpa = conc_gpa_sum/conc_course_count;
		%> <h4>&nbsp;&nbsp;&nbsp;Concentration GPA: <%=quarter_cum_gpa %> </h4> <%
		if (quarter_cum_gpa < result_rs_conc.getDouble("gpa"))
			incomplete_req++;
		
		//determine if conc is completed and add to list
		%> <h4>&nbsp;&nbsp;&nbsp;Incomplete Requirements: <%=incomplete_req %> </h4> <%
		if (incomplete_req==0)
			completed_conc = completed_conc + "," + result_rs_conc.getString("name");
	}
	
	%>
	<br>
	<br>
	<h3>Completed Conc: </h3>
	<%
	for (String concname : completed_conc.split(","))
	{
		%>&nbsp;&nbsp;&nbsp;<%=concname %> <%
	}
	%>
	
	
</body>
<!-- =============== -->
<!-- HTML Body End -->
<!-- =============== -->

<%

if (conn != null)
	conn.close();
if (pstmt1!=null)
	pstmt1.close();
if (pstmt2!=null)
	pstmt2.close();
if (pstmt3!=null)
	pstmt3.close();
if (pstmt4!=null)
	pstmt4.close();
if (pstmt5!=null)
	pstmt5.close();
if (pstmt6!=null)
	pstmt6.close();
%>

</html>