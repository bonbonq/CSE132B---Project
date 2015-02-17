<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Student Enrollment Form</title>
</head>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*" %>
<%@page import="org.postgresql.*" %>

<!-- Java Portion start -->
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

/* ============= */
/* Insert Action */
/* ============= */
if(action!=null && action.equals("insert")){
	
	PreparedStatement insert = conn.prepareStatement(	
			"INSERT INTO student_quarter__attends (idstudent, idquarter) " +
			"SELECT ?,?" +
			"WHERE EXISTS (SELECT * FROM student WHERE idstudent=?)");
	insert.setInt(1, Integer.parseInt(request.getParameter("idstudent")));
	insert.setInt(2, Integer.parseInt(request.getParameter("idquarter")));
	insert.setInt(3, Integer.parseInt(request.getParameter("idstudent")));
	
	
	if (insert.executeUpdate()==1) {
		%>
		<h1>Successfully Added!</h1>
		<%
	}
	else {
		%>
		<h1>Insert has failed! Please check if student pid is correct.</h1>
		<%
	}
}

/* ============= */
/* Update Action */
/* ============= */
else if(action!=null && action.equals("update")){
	
	PreparedStatement update = conn.prepareStatement(	
			"Update student_quarter__attends SET " +
			"idstudent=?, idquarter=? " +
			"WHERE idstudent_quarter__attends=?");
	update.setInt(1, Integer.parseInt(request.getParameter("idstudent")));
	update.setInt(2, Integer.parseInt(request.getParameter("idquarter")));
	update.setInt(3, Integer.parseInt(request.getParameter("idstudent_quarter__attends")));
	
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
	String table_name = "student_quarter__attends";
	String table_id = "idstudent_quarter__attends";
	String id_parameter_name = "idstudent_quarter__attends";
	
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

/* =========================== */
/* Generate Form Fields Action */
/* =========================== */

ResultSet quarter_rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	PreparedStatement quarter_stmt = conn.prepareStatement("SELECT * FROM quarter ORDER BY year", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	/* The below two statements are not closed, this might cause issues later... */
	quarter_rs = quarter_stmt.executeQuery();
	
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

/* ========================= */
/* EDIT FORM DATA GENERATION */
/* ========================= */

ResultSet rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	/* The below statements are not closed, this might cause issues later... */
	rs = conn.prepareStatement("SELECT * FROM student_quarter__attends NATURAL JOIN student NATURAL JOIN quarter", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE).executeQuery();
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
<h2>Degree Creation and Requirements</h2>
<!--  Insertion Form -->
	<form action="student_enroll_quarter_form.jsp" method="POST">
		
		<div>
			PID: <input type="number" name="idstudent" required>
			<br>
		</div>
		<p>
		
		<div>
			Quarter:
			<select name="idquarter">
				<%
				if (quarter_rs.isBeforeFirst())
				{
					while(quarter_rs.next()){
						%>
						<option value=<%=quarter_rs.getString("idquarter")%>><%=quarter_rs.getString("year")%> - <%=quarter_rs.getString("season")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>
	<br>
	<br>
	<!-- Edit Form -->
	<h2>Edit Form</h2>
	
	<table>
	  <tr>
	    <th>Student</th>
	    <th>Quarter</th>
	    <th>Edit Actions</th>
	  </tr>
	  <%
		if (rs.isBeforeFirst()) {
			while(rs.next()) { 
			%>
				<form action="student_enroll_quarter_form.jsp" method="POST">
					<input type="hidden" name="idstudent_quarter__attends" value="<%=rs.getString("idstudent_quarter__attends") %>">
					<input type="hidden" name="idstudent" value="<%=rs.getString("idstudent") %>">
		  			<tr>
					    <td><%=rs.getString("first_name") %> <%=rs.getString("last_name") %></td>
					    <td>
					    	<select name="idquarter">
								<%
								quarter_rs.beforeFirst();
								if (quarter_rs.isBeforeFirst())
								{
									while(quarter_rs.next()){
										%>
										<option value=<%=quarter_rs.getString("idquarter")%>  <%= rs.getString("idquarter").equals(quarter_rs.getString("idquarter")) ? "selected" : "" %>><%=quarter_rs.getString("year")%>-<%=quarter_rs.getString("season")%></option>
										<%
									}
								}
								%>
							</select>
						</td>
					    <td>
							&nbsp;
							<button type="submit" name="action" value="update">Update</button>
							&nbsp;
							<button type="submit" name="action" value="delete">Delete</button>
						</td>
					</tr>
			 	</form>
					
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