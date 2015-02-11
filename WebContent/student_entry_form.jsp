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




/* ============= */
/* Insert Action */
/* ============= */

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

/* ============= */
/* Update Action */
/* ============= */
else if(action!=null && action.equals("update")){
	
	PreparedStatement update = conn.prepareStatement(	
			"Update student SET " +
			"first_name = ?, last_name=?, middle_name=?, ss_num=?, enrolled=?, residency=? " +
			"WHERE idstudent=?");
	update.setString(1, request.getParameter("first_name"));
	update.setString(2, request.getParameter("last_name"));
	update.setString(3, request.getParameter("middle_name").trim().length()==0 ? "NULL" : request.getParameter("middle_name"));
	update.setInt(4, Integer.parseInt(request.getParameter("ss_num")));
	update.setBoolean(5, request.getParameter("enrollment").equals("True") ? true : false);
	update.setString(6, request.getParameter("residency"));
	update.setInt(7, Integer.parseInt(request.getParameter("idstudent")));
	
	if (update.executeUpdate()==1) {
		%>
		<h1>Successfully Updated!</h1>
		<%
	}
	else {
		%>
		<h1>Update has failed!</h1>
		<%
	}
}

/* ============= */
/* Delete Action */
/* ============= */

else if(action!=null && action.equals("delete")) {

	/* Just change these */
	String table_name = "student";
	String table_id = "idstudent";
	String id_parameter_name = "idstudent";
	
	PreparedStatement delete = conn.prepareStatement("DELETE FROM " + table_name + " WHERE " + table_id + "=?");
	delete.setInt(1, Integer.parseInt(request.getParameter(id_parameter_name)));
	
	if (delete.executeUpdate()==1) {
		%>
		<h1>Successfully Deleted!</h1>
		<%
	}
	else {
		%>
		<h1>Delete has failed!</h1>
		<%
	}
	
}


/* ========================= */
/* EDIT FORM DATA GENERATION */
/* ========================= */

ResultSet student_rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	/* The below statements are not closed, this might cause issues later... */
	student_rs = conn.prepareStatement("SELECT * FROM student").executeQuery();
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

	<a href='index.jsp'><button>Home</button></a>
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
	
	<br>
	<br>
	
	<!-- Student Update/Delete Form -->
	<h2>Student Edit Form</h2>
	
	<br>
	<table>
	  <tr>
	    <th>PID</th>
	    <th>First Name</th>
	    <th>Last Name</th>
	    <th>Middle Name</th>
	    <th>Social Security</th>
	    <th>Enrolled?</th>
	    <th>Residency</th>
	    <th>Update Actions</th>
	  </tr>
	  
	  
	  <%
	  if (student_rs.isBeforeFirst()) {
          
		  while(student_rs.next()) {
			  %>
			<tr>
				<form action="student_entry_form.jsp" method="POST">
					<td><input type="hidden" name="idstudent" value="<%=student_rs.getString("idstudent") %>"><%=student_rs.getString("idstudent") %></td>
					<td><input type="text" name="first_name" value="<%=student_rs.getString("first_name") %>" required></td>
					<td><input type="text" name="last_name" value="<%=student_rs.getString("last_name") %>" required></td>
					<td><input type="text" name="middle_name" value="<%=student_rs.getString("middle_name").equals("NULL") ? "" : student_rs.getString("middle_name") %>" ></td>
					<td><input type="number" name="ss_num" value="<%=student_rs.getString("ss_num") %>" required></td>
					<td>
						&nbsp;
						<input type="radio" name="enrollment" value="True" <%= student_rs.getString("enrolled").trim().equals("t") ? "checked" : "" %> >Yes
						<input type="radio" name="enrollment" value="False" <%= student_rs.getString("enrolled").trim().equals("f") ? "checked" : "" %> >No
						&nbsp;
					</td>
					<td>
						&nbsp;
						<input type="radio" name="residency" value="ca" <%= student_rs.getString("residency").trim().equals("ca") ? "checked" : "" %>>California Resident<br>
						&nbsp;
						<input type="radio" name="residency" value="nonca" <%= student_rs.getString("residency").trim().equals("nonca") ? "checked" : "" %>>Non-California Resident<br>
						&nbsp;
						<input type="radio" name="residency" value="foreign" <%= student_rs.getString("residency").trim().equals("foreign") ? "checked" : "" %>>Foreign Resident<br>
						&nbsp;
					</td>
					<td>
						&nbsp;
						<button type="submit" name="action" value="update">Update</button>
						&nbsp;
						<button type="submit" name="action" value="delete">Delete</button>
					</td>
				</form>
			</tr>
			  <%
		  }
	  }
	  %>
	  
	</table>
	
</body>
<!-- HTML Body End -->

<%

if (conn != null)
	conn.close();
%>
</html>