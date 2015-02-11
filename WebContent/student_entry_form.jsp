<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Student Entry Form</title>
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
String first_name;
String last_name;
String middle_name;
int ss_num;
boolean enrollment = false;
String residency;
int idstudent = 0;

/* Insert Action */
if (action!=null && action.equals("insert")) {
	
	first_name = request.getParameter("first_name");
	last_name = request.getParameter("last_name");
	middle_name = request.getParameter("middle_name");
	if (middle_name.length()==0) {
		middle_name = "NULL";
	}
	ss_num = Integer.parseInt(request.getParameter("ss_num"));
	if(request.getParameter("enrollment").equals("True")){
		enrollment = true;
	}
	residency = request.getParameter("residency");
	
	if (debug){
		
		System.out.println(first_name + " " + last_name);
		System.out.println("middle name: " + middle_name);
		System.out.println(middle_name.length());
		System.out.println(ss_num);
		System.out.println("enrolled? "+enrollment);
		System.out.println(residency);
		
	}
	
	try {
		conn.setAutoCommit(false);
		sql1 =	"INSERT INTO student (first_name, last_name, middle_name, ss_num, enrolled, residency) "+
				"SELECT ?,?,?,?,?,?" +
				"RETURNING idstudent";
		pstmt1 = conn.prepareStatement(sql1);
		pstmt1.setString(1, first_name);
		pstmt1.setString(2, last_name);
		pstmt1.setString(3, middle_name);
		pstmt1.setInt(4, ss_num);
		pstmt1.setBoolean(5, enrollment);
		pstmt1.setString(6, residency);
		
		if (pstmt1.execute())
		{
			ResultSet rs1 = pstmt1.getResultSet();
			if (rs1.next()){
				idstudent = rs1.getInt("idstudent");
			}
		}
		else
		{
			conn.rollback();
			throw new SQLException("Insert into student failed.");
		}
		
		conn.commit();
		conn.setAutoCommit(true);
		if (idstudent!=0)
			success = true;
		
	} catch (SQLException e) {
		conn.rollback();
		e.printStackTrace();
        String message = "Failure: Your entry failed " + e.getMessage();
	   	%>
		<h1><%=message %></h1>
		<%
	} finally {
		if (pstmt1 != null)
			pstmt1.close();
	}
	
	if (success) {
		String message = "Successfully added new student with PID: " + idstudent;
		%>
		<h1><%=message %></h1>
		<%
	}
}
%>




<!-- HTML body part -->
<body>

	<h2>Student Entry Form</h2>
	
	<!-- Student Insertion Form -->
	<form action="student_entry_form.jsp" method="POST">
		
		<div>
			First Name: <input type="text" name="first_name" required>
			<br>
			Last Name: <input type="text" name="last_name" required>
			<br>
			Middle Name: <input type="text" name="middle_name">
			<br>
			Social Security Number (without the dashes) : <input type="number" name="ss_num" required>
		</div>
		<p>
		
		<p>
		
		<div>
			Enrolled? 
			<br>
			<input type="radio" name="enrollment" value="True" checked>Yes<br>
			<input type="radio" name="enrollment" value="False">No<br>
			<br>
		</div>
		<p>
		
		<div>
			Residency: 
			<br>
			<input type="radio" name="residency" value="ca" checked>California Resident<br>
			<input type="radio" name="residency" value="nonca">Non-California Resident<br>
			<input type="radio" name="residency" value="foreign">Foreign Resident<br>
			<br>
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