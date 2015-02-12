<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Probation Information Form</title>
</head>

<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>

<%
	Connection conn = null;
	try {
		Class.forName("org.postgresql.Driver");
		conn = DriverManager.getConnection(
	            "jdbc:postgresql://localhost/CSE132B?");
		
	} catch (Exception e) {
		e.printStackTrace();
		out.println("<h1>org.postgresql.Driver Not Found</h1>");
	}

	String action = request.getParameter("action");
	/* Insert Action */
	if (action != null && action.equals("insert"))
	{
		PreparedStatement update = conn.prepareStatement(	
				"INSERT INTO student_quarter__probation (idstudent, idquarter, reason) " +
				"SELECT ?,?,? ");
		update.setInt(1, Integer.parseInt(request.getParameter("idstudent")));
		update.setInt(2, Integer.parseInt(request.getParameter("idquarter")));
		update.setString(3, request.getParameter("reason"));
		
		if (update.executeUpdate()==1) {
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
	/* ============= */
	/* Update Action */
	/* ============= */
	else if(action!=null && action.equals("update")){
		
		PreparedStatement update = conn.prepareStatement(	
				"Update student_quarter__probation SET " +
				"reason = ? " +
				"WHERE idstudent_quarter__probation=?");
		update.setString(1, request.getParameter("reason"));
		update.setInt(2, Integer.parseInt(request.getParameter("idstudent_quarter__probation")));
		
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
		String table_name = "student_quarter__probation";
		String table_id = "idstudent_quarter__probation";
		String id_parameter_name = "idstudent_quarter__probation";
		
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
	/* insert FORM DATA GENERATION */
	/* ========================= */

	ResultSet quarter_rs = null;

	//The following will always run regardless of action
	try{
		conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
		conn.setAutoCommit(false);
		/* The below statements are not closed, this might cause issues later... */
		quarter_rs = conn.prepareStatement("SELECT * FROM quarter").executeQuery();
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
		conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
		conn.setAutoCommit(false);
		/* The below statements are not closed, this might cause issues later... */
		rs = conn.prepareStatement("SELECT * FROM student_quarter__probation NATURAL JOIN student NATURAL JOIN quarter").executeQuery();
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
<body>

	<h2>Probation Information Submission</h2>
	
	<!-- Insert Form -->
	<form action="probation_info_submission.jsp" method="post">
		Student ID:
		<input type="text" name="idstudent"><br><br>
		Quarter
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
		<br>
		Reason For Probation:<br>
		<textarea rows="5" cols="50" name="reason"></textarea>
		<br><br>
	<button type="submit" name="action" value="insert">Insert</button>
	</form>
	
	<!-- Edit Form -->
	<h2>Edit Form</h2>
	
	<table>
	  <tr>
	    <th>Student Name</th>
	    <th>Quarter</th>
	    <th>Reason</th>
	    <th>Edit Actions</th>
	  </tr>
	  <%
		if (rs.isBeforeFirst()) {
			while(rs.next()) { 
			%>
				<form action="probation_info_submission.jsp" method="POST">
					<input type="hidden" name="idstudent_quarter__probation" value="<%=rs.getString("idstudent_quarter__probation") %>">
		  			<tr>
					    <td><%=rs.getString("idstudent") %> - <%=rs.getString("first_name") %> <%=rs.getString("last_name") %></td>
					    <td><%=rs.getInt("year") %> <%=rs.getString("season") %></td>
					    <td>
					    	<textarea rows="5" cols="50" name="reason"><%=rs.getString("reason") %></textarea>
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
</html>