<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Graduate Entry Form</title>
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
String type;
int department;
int degree;
String advisor = "";

/* =========================== */
/* Insert Action */
/* =========================== */

if (action!=null && action.equals("insert")) {
	
	pid = Integer.parseInt(request.getParameter("pid"));
	type = request.getParameter("type");
	department = Integer.parseInt(request.getParameter("department"));
	degree = Integer.parseInt(request.getParameter("degree"));
	advisor = request.getParameter("advisor").replaceAll("_", " ");
	
	if (debug) {
		System.out.println("pid: " + pid);
		System.out.println("type:" + type);
		System.out.println("department: " + department);
		System.out.println("advisor: " + advisor);
	}
	
	int idms = 0;
	
	try {
		conn.setAutoCommit(false);
		if (type.equals("ms") || type.equals("5year")) {
			
			sql1 = "INSERT INTO ms (idstudent) SELECT ? "+
					"WHERE NOT EXISTS (SELECT idms FROM ms WHERE idstudent=?) "+
					"AND EXISTS (SELECT idstudent FROM student WHERE idstudent=?) "+
					"AND NOT EXISTS (SELECT idcandidate FROM candidate WHERE idstudent=?)" +
					"AND NOT EXISTS (SELECT idprecandidate FROM precandidate WHERE idstudent=?)" +
					"and NOT EXISTS (SELECT idundergraduate FROM undergraduate WHERE idstudent=?)" +
					"RETURNING idms";
			pstmt1 = conn.prepareStatement(sql1);
			pstmt1.setInt(1, pid);
			pstmt1.setInt(2, pid);
			pstmt1.setInt(3, pid);
			pstmt1.setInt(4, pid);
			pstmt1.setInt(5, pid);
			pstmt1.setInt(6, pid);
			if (pstmt1.execute())
			{
				ResultSet rs1 = pstmt1.getResultSet();
				if (rs1.next()){
					idms = rs1.getInt("idms");
				}
				else {
					throw new SQLException("That student is already registered or the student doesn't exist.");
				}
			}
			else
			{
				throw new SQLException("Insert into ms failed.");
			}
			
			if (idms!=0){
				
				/* Insert into graduate_department if idms returned */
				sql2 = "INSERT INTO graduate_department (idstudent, iddepartment) SELECT ?,? WHERE NOT EXISTS (SELECT idgraduate_department FROM graduate_department WHERE idstudent=?) RETURNING idgraduate_department";
				pstmt2 = conn.prepareStatement(sql2);
				pstmt2.setInt(1, pid);
				pstmt2.setInt(2, department);
				pstmt2.setInt(3, pid);
				if (pstmt2.execute())
				{
					ResultSet rs2 = pstmt2.getResultSet();
					if (rs2.next()){
						if(rs2.getInt("idgraduate_department") > 0)
							success = true;
					}
					else {
						throw new SQLException("That student is already registered in a department.");
					}
				}
				else
				{
					throw new SQLException("Insert into graduate_department failed.");
				}
				
				/* Insert into undergraduate_ms if 5 year */
				if (type.equals("5year")) {
					success = false;
					sql3 = "INSERT INTO undergraduate_ms (idstudent, idms) SELECT ?,? WHERE NOT EXISTS (SELECT idundergraduate_ms FROM undergraduate_ms WHERE idstudent=?) AND EXISTS (SELECT idstudent FROM student WHERE idstudent=?) RETURNING idundergraduate_ms";
					pstmt3 = conn.prepareStatement(sql3);
					pstmt3.setInt(1, pid);
					pstmt3.setInt(2, idms);
					pstmt3.setInt(3, pid);
					pstmt3.setInt(4, pid);
					if (pstmt3.execute())
					{
						ResultSet rs3 = pstmt3.getResultSet();
						if (rs3.next()){
							if(rs3.getInt("idundergraduate_ms") > 0)
								success = true;
						}
						else {
							throw new SQLException("That student is already registered as a 5-year MS student.");
						}
					}
					else
					{
						throw new SQLException("Insert into undergraduate_ms failed.");
					}
				}
				
				/* Insert into graduate_degree */
				success = false;
				sql4 = "INSERT INTO graduate_degree (idstudent, iddegree) SELECT ?,? WHERE NOT EXISTS (SELECT idgraduate_degree FROM graduate_degree WHERE idstudent=?) RETURNING idgraduate_degree";
				pstmt4 = conn.prepareStatement(sql4);
				pstmt4.setInt(1, pid);
				pstmt4.setInt(2, degree);
				pstmt4.setInt(3, pid);
				if (pstmt4.execute())
				{
					ResultSet rs4 = pstmt4.getResultSet();
					if (rs4.next()){
						if(rs4.getInt("idgraduate_degree") > 0)
							success = true;
					}
					else {
						throw new SQLException("That student is already registered for a degree.");
					}
				}
				else
				{
					throw new SQLException("Insert into graduate_degree failed.");
				}
			}
			
		}
		else if (type.equals("precandidate")) {
			
			int idprecandidate = 0;
			
			sql1 = "INSERT INTO precandidate (idstudent) SELECT ? WHERE NOT EXISTS (SELECT idprecandidate FROM precandidate WHERE idstudent=?) AND EXISTS (SELECT idstudent FROM student WHERE idstudent=?) RETURNING idprecandidate";
			pstmt1 = conn.prepareStatement(sql1);
			pstmt1.setInt(1, pid);
			pstmt1.setInt(2, pid);
			pstmt1.setInt(3, pid);
			if (pstmt1.execute())
			{
				ResultSet rs1 = pstmt1.getResultSet();
				if (rs1.next()){
					idprecandidate = rs1.getInt("idprecandidate");
				}
				else {
					throw new SQLException("That student is already registered as an pre-candidate student or the student does not exist.");
				}
			}
			else
			{
				throw new SQLException("Insert into precandidate failed.");
			}
			
			if (idprecandidate!=0){
				sql2 = "INSERT INTO graduate_department (idstudent, iddepartment) SELECT ?,? WHERE NOT EXISTS (SELECT idgraduate_department FROM graduate_department WHERE idstudent=?) RETURNING idgraduate_department";
				pstmt2 = conn.prepareStatement(sql2);
				pstmt2.setInt(1, pid);
				pstmt2.setInt(2, department);
				pstmt2.setInt(3, pid);
				if (pstmt2.execute())
				{
					ResultSet rs2 = pstmt2.getResultSet();
					if (rs2.next()){
						if(rs2.getInt("idgraduate_department") > 0)
							success = true;
					}
					else {
						throw new SQLException("That student is already registered in a department.");
					}
				}
				else
				{
					throw new SQLException("Insert into graduate_department failed.");
				}
			}
			
			/* NOTE: THERE IS NO sql3 or pstmt3 */
			
			/* Insert into graduate_degree */
			success = false;
			sql4 = "INSERT INTO graduate_degree (idstudent, iddegree) SELECT ?,? WHERE NOT EXISTS (SELECT idgraduate_degree FROM graduate_degree WHERE idstudent=?) RETURNING idgraduate_degree";
			pstmt4 = conn.prepareStatement(sql4);
			pstmt4.setInt(1, pid);
			pstmt4.setInt(2, degree);
			pstmt4.setInt(3, pid);
			if (pstmt4.execute())
			{
				ResultSet rs4 = pstmt4.getResultSet();
				if (rs4.next()){
					if(rs4.getInt("idgraduate_degree") > 0)
						success = true;
				}
				else {
					throw new SQLException("That student is already registered for a degree.");
				}
			}
			else
			{
				throw new SQLException("Insert into graduate_degree failed.");
			}
			
		}
		else if (type.equals("candidate")) {
			if (advisor.length() == 0) {
				throw new SQLException("Please fill in an advisor.");
			}
			
			int idcandidate = 0;
			
			sql1 = "INSERT INTO candidate (idstudent) SELECT ? WHERE NOT EXISTS (SELECT idcandidate FROM candidate WHERE idstudent=?) AND EXISTS (SELECT idstudent FROM student WHERE idstudent=?) RETURNING idcandidate";
			pstmt1 = conn.prepareStatement(sql1);
			pstmt1.setInt(1, pid);
			pstmt1.setInt(2, pid);
			pstmt1.setInt(3, pid);
			if (pstmt1.execute())
			{
				ResultSet rs1 = pstmt1.getResultSet();
				if (rs1.next()){
					idcandidate = rs1.getInt("idcandidate");
				}
				else {
					throw new SQLException("That student is already registered as an pre-candidate student or the student does not exist.");
				}
			}
			else
			{
				throw new SQLException("Insert into precandidate failed.");
			}
			
			if (idcandidate!=0){
				sql2 = "INSERT INTO graduate_department (idstudent, iddepartment) SELECT ?,? WHERE NOT EXISTS (SELECT idgraduate_department FROM graduate_department WHERE idstudent=?) RETURNING idgraduate_department";
				pstmt2 = conn.prepareStatement(sql2);
				pstmt2.setInt(1, pid);
				pstmt2.setInt(2, department);
				pstmt2.setInt(3, pid);
				if (pstmt2.execute())
				{
					ResultSet rs2 = pstmt2.getResultSet();
					if (rs2.next()){
						if(rs2.getInt("idgraduate_department") > 0)
							success = true;
					}
					else {
						throw new SQLException("That student is already registered in a department.");
					}
				}
				else
				{
					throw new SQLException("Insert into graduate_department failed.");
				}
				
				success = false;
				sql3 = "INSERT INTO faculty_candidate (faculty_name, idcandidate) SELECT ?,? RETURNING idfaculty_candidate";
				pstmt3 = conn.prepareStatement(sql3);
				pstmt3.setString(1, advisor);
				pstmt3.setInt(2, idcandidate);
				if (pstmt3.execute())
				{
					ResultSet rs3 = pstmt3.getResultSet();
					if (rs3.next()){
						if(rs3.getInt("idfaculty_candidate") > 0)
							success = true;
					}
					else {
						throw new SQLException("That student is already registered in a department.");
					}
				}
				else
				{
					throw new SQLException("Insert into graduate_department failed.");
				}
				
				/* Insert into graduate_degree */
				success = false;
				sql4 = "INSERT INTO graduate_degree (idstudent, iddegree) SELECT ?,? WHERE NOT EXISTS (SELECT idgraduate_degree FROM graduate_degree WHERE idstudent=?) RETURNING idgraduate_degree";
				pstmt4 = conn.prepareStatement(sql4);
				pstmt4.setInt(1, pid);
				pstmt4.setInt(2, degree);
				pstmt4.setInt(3, pid);
				if (pstmt4.execute())
				{
					ResultSet rs4 = pstmt4.getResultSet();
					if (rs4.next()){
						if(rs4.getInt("idgraduate_degree") > 0)
							success = true;
					}
					else {
						throw new SQLException("That student is already registered for a degree.");
					}
				}
				else
				{
					throw new SQLException("Insert into graduate_degree failed.");
				}
			}
		}
		
		conn.commit();
		conn.setAutoCommit(true);
		
	}	catch (SQLException e) {
		conn.rollback();
		e.printStackTrace();
		      String message = "Failure: Your entry failed " + e.getMessage();
		  	%>
		<h1><%=message %></h1>
		<%
	}	finally {
		if (pstmt1 != null)
			pstmt1.close();
		if (pstmt2 != null)
			pstmt2.close();
		if (pstmt3 != null)
			pstmt3.close();
	}
	
	if (success) {
		String message = "Successfully registered new graduate student";
		%>
		<h1><%=message %></h1>
		<%
	}
}


/* =========================== */
/* Generate Form Fields Action */
/* =========================== */

ResultSet department_rs = null;
ResultSet faculty_rs = null;
ResultSet degree_rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	PreparedStatement department_stmt = conn.prepareStatement("SELECT * FROM department");
	PreparedStatement faculty_stmt = conn.prepareStatement("SELECT * FROM faculty");
	PreparedStatement degree_stmt = conn.prepareStatement("SELECT * FROM degree WHERE type='MS' OR type='PHD'");
	/* The below two statements are not closed, this might cause issues later... */
	department_rs = department_stmt.executeQuery();
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

	<a href='index.jsp'><button>Home</button></a>
	<h2>Graduate Entry Form</h2>
	
	<!-- Student Insertion Form -->
	<form action="graduate_entry_form.jsp" method="POST">
		
		<div>
			PID: <input type="number" name="pid" required>
			<br>
		</div>
		<p>
		
		<div>
			Type: 
			<br>
			<input type="radio" name="type" value="ms" checked>MS<br>
			<input type="radio" name="type" value="5year" >5 Year BS/MS<br>
			<input type="radio" name="type" value="precandidate" >Ph.D. (pre-candidacy)<br>
			<input type="radio" name="type" value="candidate" >Ph.D. (candidate)<br>
			<br>
		</div>
		<p>
		
		<div>
			Department:
			<select name="department">
				<%
				if (department_rs.isBeforeFirst())
				{
					while(department_rs.next()){
						%>
						<option value=<%=department_rs.getString("iddepartment")%>><%=department_rs.getString("name")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<div>
			Degree:
			<select name="degree">
				<%
				if (degree_rs.isBeforeFirst())
				{
					while(degree_rs.next()){
						%>
						<option value=<%=degree_rs.getString("iddegree")%>><%=degree_rs.getString("name")%> - <%=degree_rs.getString("type")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<div>
			For Ph.D. candidates only:
			<br>
			Advisor: 
			<select name="advisor">
				<option value="NULL"></option>
				<%
				if (faculty_rs.isBeforeFirst())
				{
					while(faculty_rs.next()){
						String faculty_name = faculty_rs.getString("faculty_name").replaceAll(" ", "_");
						%>
						<option value=<%=faculty_name%>><%=faculty_rs.getString("faculty_name")%></option>
						<%
					}
				}
				%>
			</select>
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