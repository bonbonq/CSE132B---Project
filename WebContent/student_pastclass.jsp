<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Student Past Class Form</title>
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
String faculty_name;
int idinstance;

/* ================== */
/* INSERT FORM ACTION */
/* ================== */
if (action!=null && action.equals("insert")) {
	try {
		conn.setAutoCommit(false);
		
		/* Insert into student_pastclass */
		sql1 =	"INSERT INTO student_pastclass (idstudent, idclass) SELECT ?,? WHERE NOT EXISTS (SELECT idstudent_pastclass FROM student_pastclass WHERE idstudent=? and idclass=?) RETURNING idstudent_pastclass";
		pstmt1 = conn.prepareStatement(sql1);
		pstmt1.setInt(1, Integer.parseInt(request.getParameter("idstudent")));
		pstmt1.setInt(2, Integer.parseInt(request.getParameter("idclass")));
		pstmt1.setInt(3, Integer.parseInt(request.getParameter("idstudent")));
		pstmt1.setInt(4, Integer.parseInt(request.getParameter("idclass")));

		if (pstmt1.execute())
		{
			ResultSet rs1 = pstmt1.getResultSet();
			if (rs1.next()){
				if (rs1.getInt("idstudent_pastclass") > 0)
					success = true;
			}
		}
		else
		{
			conn.rollback();
			throw new SQLException("Insert into faculty_instance_teaches failed.");
		}
		
		conn.commit();
		conn.setAutoCommit(true);
		
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
		String message = "Successfully registered student's old class.";
		%>
		<h1><%=message %></h1>
		<%
	}
	else {
		String message = "Unsuccessfully registration.";
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
			"Update student_pastclass SET " +
			"idclass=?" +
			"WHERE idstudent_pastclass=?");
	update.setInt(1, Integer.parseInt(request.getParameter("idclass")));
	update.setInt(2, Integer.parseInt(request.getParameter("idstudent_pastclass")));
	
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
	String table_name = "student_pastclass";
	String table_id = "idstudent_pastclass";
	String id_parameter_name = "idstudent_pastclass";
	
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

ResultSet rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	/* The below statements are not closed, this might cause issues later... */
	rs = conn.prepareStatement("SELECT * FROM student_pastclass NATURAL JOIN class NATURAL JOIN student").executeQuery();
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
	<h2>Student Past Class Form</h2>
	
	<!-- Student Insertion Form -->
	<form action="student_pastclass.jsp" method="POST">
		
		<div>
			PID: <input type="number" name="idstudent" required>
			<br>
		</div>
		<p>
		
		<div>
			Class ID: <input type="number" name="idclass" required>
			<br>
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
	    <th>Student Name</th>
	    <th>Class ID</th>
	    <th>Edit Actions</th>
	  </tr>
	  <%
		if (rs.isBeforeFirst()) {
			while(rs.next()) { 
			%>
				<form action="student_pastclass.jsp" method="POST">
					<input type="hidden" name="idstudent_pastclass" value="<%=rs.getString("idstudent_pastclass") %>">
		  			<tr>
					    <td><%=rs.getString("idstudent") %> - <%=rs.getString("first_name") %> <%=rs.getString("last_name") %></td>
					    <td><input type="text" name="idclass" value="<%=rs.getString("idclass") %>" required></td>
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