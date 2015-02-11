<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Student's Previous Degree Entry Form</title>
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
int pid;
int school;
int degree;
ResultSet school_rs = null;
ResultSet degree_rs = null;

/* Insert Action */
if (action!=null && action.equals("insert")) {
	
	pid = Integer.parseInt(request.getParameter("pid"));
	school = Integer.parseInt(request.getParameter("school"));
	degree = Integer.parseInt(request.getParameter("degree"));
	
	if (debug){
		System.out.println("pid: " + pid);
		System.out.println("school: " + school);
		System.out.println("degree: " + degree);
	}
	
	try {
		conn.setAutoCommit(false);
		
		/* Insert into school */
		sql1 =	"INSERT INTO student_degree_school (idstudent, idpreviousdegree, idschool) "+
				"SELECT ?,?,?" +
				"WHERE NOT EXISTS (" +
					"SELECT idstudent_degree_school FROM student_degree_school WHERE idstudent=? AND idpreviousdegree=? AND idschool=?" +
				")" +
				" AND " +
				"EXISTS (" +
					"SELECT idstudent FROM student WHERE idstudent=?" +
				")" +
				"RETURNING idstudent_degree_school";
		pstmt1 = conn.prepareStatement(sql1);
		pstmt1.setInt(1, pid);
		pstmt1.setInt(2, degree);
		pstmt1.setInt(3, school);
		pstmt1.setInt(4, pid);
		pstmt1.setInt(5, degree);
		pstmt1.setInt(6, school);
		pstmt1.setInt(7, pid);
		if (pstmt1.execute())
		{
			ResultSet rs1 = pstmt1.getResultSet();
			if (rs1.next()){
				if (rs1.getInt("idstudent_degree_school") > 0)
					success = true;
			}
		}
		else
		{
			conn.rollback();
			throw new SQLException("Insert into student_degree_school failed.");
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
		String message = "Successfully added new previous degree";
		%>
		<h1><%=message %></h1>
		<%
	}
	
	else {
		String message = "Unsuccessfully added new previous degree";
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
			"Update student_degree_school SET " +
			"idpreviousdegree=?, idschool=? " +
			"WHERE idstudent_degree_school=?");
	update.setInt(1, Integer.parseInt(request.getParameter("idpreviousdegree")));
	update.setInt(2, Integer.parseInt(request.getParameter("idschool")));
	update.setInt(3, Integer.parseInt(request.getParameter("idstudent_degree_school")));
	
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
	String table_name = "student_degree_school";
	String table_id = "idstudent_degree_school";
	String id_parameter_name = "idstudent_degree_school";
	
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

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	PreparedStatement school_stmt = conn.prepareStatement("SELECT * FROM school", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	PreparedStatement degree_stmt = conn.prepareStatement("SELECT * FROM previousdegree", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	/* The below two statements are not closed, this might cause issues later... */
	school_rs = school_stmt.executeQuery();
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

/* ========================= */
/* EDIT FORM DATA GENERATION */
/* ========================= */

ResultSet rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	/* The below statements are not closed, this might cause issues later... */
	rs = conn.prepareStatement("SELECT * FROM student_degree_school NATURAL JOIN student NATURAL JOIN previousdegree NATURAL JOIN school ORDER BY idstudent").executeQuery();
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
	<h2>Student's Previous Earned Degree Entry Form</h2>
	
	<!-- Insertion Form -->
	<form action="student_previous_degree_form.jsp" method="POST">
		
		<div>
			PID: <input type="number" name="pid" required>
			<br>
		</div>
		<p>
		
		<div>
			School Name:
			<select name="school">
				<%
				if (school_rs.isBeforeFirst())
				{
					while(school_rs.next()){
						%>
						<option value=<%=school_rs.getString("idschool")%>><%=school_rs.getString("name")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<div>
			Degree Name:
			<select name="degree">
				<%
				if (degree_rs.isBeforeFirst())
				{
					while(degree_rs.next()){
						%>
						<option value=<%=degree_rs.getString("idpreviousdegree")%>><%=degree_rs.getString("field")%> - <%=degree_rs.getString("type")%></option>
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
	
	<h2></h2>
	<!-- Edit -->
	<h2>Edit Form</h2>
	
	<table>
	  <tr>
	    <th>PID - Name</th>
	    <th>School Name</th>
	    <th>Degree Name</th>
	    <th>Edit Actions</th>
	  </tr>
	  <%
		if (rs.isBeforeFirst()) {
			while(rs.next()) { 
			%>
				<form action="student_previous_degree_form.jsp" method="POST">
					<input type="hidden" name="idstudent_degree_school" value="<%=rs.getString("idstudent_degree_school") %>">
		  			<tr>
					    <td><%=rs.getString("idstudent") %> - <%=rs.getString("first_name") %> <%=rs.getString("last_name") %></td>
					    <td>
					    	<select name="idschool">
								<%
								school_rs.beforeFirst();
								if (school_rs.isBeforeFirst())
								{
									while(school_rs.next()){
										%>
										<option value=<%=school_rs.getString("idschool")%> <%= rs.getString("idschool").trim().equals(school_rs.getString("idschool")) ? "selected" : "" %> ><%=school_rs.getString("name")%></option>
										<%
									}
								}
								%>
							</select>
					    </td>
					    <td>
					    	<select name="idpreviousdegree">
								<%
								degree_rs.beforeFirst();
								if (degree_rs.isBeforeFirst())
								{
									while(degree_rs.next()){
										%>
										<option value=<%=degree_rs.getString("idpreviousdegree")%>  <%= rs.getString("idpreviousdegree").trim().equals(degree_rs.getString("idpreviousdegree")) ? "selected" : "" %>  ><%=degree_rs.getString("field")%> - <%=degree_rs.getString("type")%></option>
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
</html>