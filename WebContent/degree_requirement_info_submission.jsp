<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Degree Requirement Submission</title>

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
			"INSERT INTO degree (total_units, name, type) " +
			"SELECT ?,?,?");
	insert.setString(1, request.getParameter("total_units"));
	insert.setString(2, request.getParameter("name").trim());
	insert.setString(3, request.getParameter("type"));
	
	if (request.getParameter("name").trim().length() > 0) {
		if (insert.executeUpdate()==1) {
			%>
			<h1>Successfully Inserted!</h1>
			<%
		}
		else {
			%>
			<h1>Insert has failed!</h1>
			<%
		}
	}
	else {
		%>
		<h1>Incorrect name entry</h1>
		<%
	}
}
/* ============= */
/* Update Action */
/* ============= */
else if(action!=null && action.equals("update")){
	
	PreparedStatement update = conn.prepareStatement(	
			"Update degree SET " +
			"total_units=?, name=?, type=? " +
			"WHERE iddegree=?");
	update.setString(1, request.getParameter("total_units"));
	update.setString(2, request.getParameter("name"));
	update.setString(3, request.getParameter("type"));
	update.setInt(4, Integer.parseInt(request.getParameter("iddegree")));
	
	if (request.getParameter("name").trim().length() > 0) {
		if (update.executeUpdate()==1) {
			%>
			<h1>Successfully Update!</h1>
			<%
		}
		else {
			%>
			<h1>Update has failed!</h1>
			<%
		}
	}
	else {
		%>
		<h1>Incorrect name entry</h1>
		<%
	}
}



/* ============= */
/* Delete Action */
/* ============= */

else if(action!=null && action.equals("delete")) {

	/* Just change these */
	String table_name = "degree";
	String table_id = "iddegree";
	String id_parameter_name = "iddegree";
	
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
	rs = conn.prepareStatement("SELECT * FROM degree").executeQuery();
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


</head>
<body>
<h2>Degree Creation and Requirements</h2>
<!--  Insertion Form -->
	<form action="degree_requirement_info_submission.jsp" method="POST">
		
		<div>
			Name: <input type="text" name="name" required>
			<br>
		</div>
		<p>
		
		<div>
			Type: 
			<br>
			<input type="radio" name="type" value="BS" checked>BS<br>
			<input type="radio" name="type" value="MS">MS<br>
			<input type="radio" name="type" value="PHD">PHD<br>
			<br>
		</div>
		<p>
		
		<div>
			Units: <input type="number" name="total_units" min=0 required>
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
	    <th>Degree Name</th>
	    <th>Type</th>
	    <th>Total Units</th>
	    <th>Edit Actions</th>
	  </tr>
	  <%
		if (rs.isBeforeFirst()) {
			while(rs.next()) { 
			%>
				<form action="degree_requirement_info_submission.jsp" method="POST">
					<input type="hidden" name="iddegree" value="<%=rs.getString("iddegree") %>">
		  			<tr>
					    <td><input type="text" name="name" value="<%=rs.getString("name") %>" required></td>
					    <td><input type="text" name="type" value="<%=rs.getString("type") %>" required></td>
					    <td><input type="text" name="total_units" value="<%=rs.getString("total_units") %>" required></td>
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