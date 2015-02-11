<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Course Enrollment</title>
</head>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*" %>
<%@page import="org.postgresql.*" %>

<!-- Java Part Start -->

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
int idquarter = 0;

/* ============================== */
/* Continue from precourse action */
/* ============================== */

if (action!=null && action.equals("precourse")) {
	idquarter = Integer.parseInt(request.getParameter("quarter"));
	if (idquarter==0)
		response.sendRedirect("precourse_enrollment.jsp");
}
else {
	response.sendRedirect("precourse_enrollment.jsp");
}

/* =========================== */
/* Generate Form Fields Action */
/* =========================== */

ResultSet instance_rs = null;
ResultSet faculty_rs = null;
ResultSet degree_rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	PreparedStatement instance_stmt = conn.prepareStatement("SELECT * FROM quarter_course_class__instance WHERE idquarter=?");
	instance_stmt.setInt(1, idquarter);
	PreparedStatement faculty_stmt = conn.prepareStatement("SELECT * FROM faculty");
	PreparedStatement degree_stmt = conn.prepareStatement("SELECT * FROM degree WHERE type='MS' OR type='PHD'");
	/* The below two statements are not closed, this might cause issues later... */
	instance_rs = instance_stmt.executeQuery();
	faculty_rs = faculty_stmt.executeQuery();
	degree_rs = degree_stmt.executeQuery();
	
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

<!-- HTML body part -->
<body>

	<h2>Course Enrollment Form</h2>

	<!-- Insertion Form -->
	<form action="course_enrollment.jsp" method="POST">
		
		<input type="hidden" name="quarter" value="<%=idquarter %>">
		
		<div>
			PID: <input type="text" name="pid" required>
			<br>
		</div>
		<p>
		
		<div>
			Course number:
			<select name="course_number" required>
				<option value="course1">Test Course 1</option>
				<option value="course2">Test Course 2</option>
			</select>
		</div>	
		<p>
		
		<div>
			If multiple sections in course:
			<br>
			Section Number: <input type="text" name="section_number">
			<br>
		</div>
		<p>
		
		<div>
			<br>
			Units: <input type="number" name="units" required>
			<br>
		</div>
		<p>
		
		<div>
			Grade Type:
			<br>
			<input type="radio" name="grade_type" value="letter" checked>Letter</input><br>
			<input type="radio" name="grade_type" value="su" >S/U</input>
		</div>
		<p>
		
		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>


</body>
<!-- HTML Body End -->

<%

if (conn != null)
	conn.close();
%>

</html>