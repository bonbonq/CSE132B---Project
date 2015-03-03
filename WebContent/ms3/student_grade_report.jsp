<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Student Grade Report</title>
</head>
</head>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*" %>
<%@page import="org.postgresql.*" %>
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
if (action!=null && action.equals("submit")) {
	System.out.println("test");

	//The following will always run regardless of action
	try{
		conn.setAutoCommit(false);
		pstmt1 = conn.prepareStatement(
				"SELECT * FROM student_section__enrolled NATURAL JOIN faculty_class_section NATURAL JOIN student_instance NATURAL JOIN quarter_course_class__instance NATURAL JOIN course_coursenumber NATURAL JOIN coursenumber NATURAL JOIN quarter WHERE idstudent = ? ORDER BY quarter.idquarter",
				ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
		pstmt1.setInt(1, Integer.parseInt(request.getParameter("ss_num")));
		result_rs = pstmt1.executeQuery();

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
}

/* =========================== */
/* Generate Form Fields Action */
/* =========================== */

ResultSet form_rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	int current_year = Calendar.getInstance().get(Calendar.YEAR);
	pstmt2 = conn.prepareStatement(
			"SELECT * FROM student WHERE EXISTS (SELECT * FROM student_quarter__attends)",
			ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	/* The below two statements are not closed, this might cause issues later... */
	form_rs = pstmt2.executeQuery();

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
	<h2>Student's Grade Report</h2>
	
	<!-- Student Insertion Form -->
	<form action="student_grade_report.jsp" method="POST">
		
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
		
		<button type="submit" name="action" value="submit">Submit</button>
		
	</form>
	<br>
	<br>
	
	<!-- Edit Form -->
	<h2>Edit Form</h2>
	
	<table>
	  <tr>
	    <th>Course Number</th>
	    <th>Grade Option Selected</th>
	    <th>Units</th>
	    <th>Grade</th>
	    <th>Section Id</th>
	  </tr>
	  <%
	  	Hashtable<String, Double> grade_conversion = new Hashtable<String, Double>();
	  	grade_conversion.put("A+", 4.3);
		grade_conversion.put("A", 4.0);
		grade_conversion.put("A-", 3.7);
		grade_conversion.put("B+", 3.4);
		grade_conversion.put("B", 3.1);
		grade_conversion.put("B-", 2.8);
		grade_conversion.put("C+", 2.5);
		grade_conversion.put("C", 2.2);
		grade_conversion.put("C-", 1.9);
		grade_conversion.put("D", 1.6);
		grade_conversion.put("F", 0.0);
		int prev_id = 0;
		double total_grade = 0;
	  	double quarter_grade = 0;
	  	int num_class = 0;
	  	int total_num_class = 0;
	  	
	  	if (result_rs!=null) {
	  		if (result_rs.isBeforeFirst()) {
				while(result_rs.next()) { 
					
					int idquarter = result_rs.getInt("idquarter");
					if (prev_id==0) {
						prev_id = idquarter;
					}
					else if (prev_id!=idquarter) {
						//calculate gpa and output
						%>
						<tr>
							<td><h4>Quarter GPA: <%= quarter_grade/num_class%></h4></td>
						</tr>
						<%
						//reset counters
						num_class=0;
						quarter_grade=0;
						prev_id = idquarter;
					}
					
				%>
				
		  			<tr>
					    <td><%=result_rs.getString("year") %> <%=result_rs.getString("season") %> - <%=result_rs.getString("number") %></td>
					    <td><%=result_rs.getString("grade_option_type") %></td>
					    <td><%=result_rs.getString("units") %></td>
					    <td><%=result_rs.getString("grade") %></td>
					    <td><%=result_rs.getString("idsection") %></td>
					</tr>
						
				<%
					// only add the grade if it's got a grade
					if (!(result_rs.getString("grade").trim().equals("PENDING")) && !(result_rs.getString("grade").trim().equals("U")) && !(result_rs.getString("grade").trim().equals("S"))) {
						System.out.println(result_rs.getString("grade"));
						quarter_grade += grade_conversion.get(result_rs.getString("grade"));
						total_grade += grade_conversion.get(result_rs.getString("grade"));
						num_class++;
						total_num_class++;
					}
				}
				
				%>
				<tr>
					<td><h4>Quarter GPA: <%= quarter_grade/num_class%></h4></td>
				</tr>
				<tr>
					<td><h3>Total Grade: <%= total_grade/total_num_class %></h3></td>
				</tr>
				<%
			}	
	  	}
	  %>
	</table>
	
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
%>

</html>