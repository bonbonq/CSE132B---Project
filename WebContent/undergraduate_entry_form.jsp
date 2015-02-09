<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Undergraduate Entry Form</title>
</head>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*" %>
<%@page import="org.postgresql.*" %>

<!-- Java Part Start -->
<%
boolean debug= true;
/* =========================== */
/* Create DB connection */
/* =========================== */

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
int major;
int minor;
String college;
int idundergrdauate = 0;

/* =========================== */
/* Insert Action */
/* =========================== */

if (action!=null && action.equals("insert")) {
	
	pid = Integer.parseInt(request.getParameter("pid"));
	major = Integer.parseInt(request.getParameter("major"));
	minor = Integer.parseInt(request.getParameter("minor"));
	college = request.getParameter("college");
	
	if (debug) {
		System.out.println("pid: " + pid);
		System.out.println("major: " + major);
		System.out.println("minor: " + minor);
		System.out.println("college: " + college);
	}
	
	try {
		conn.setAutoCommit(false);
		
		if (major!=minor){
			
			/* Insert into undergraduate table */
			sql1 = "INSERT INTO undergraduate (college, idstudent)" +
					"SELECT ?,?" +
					"WHERE NOT EXISTS (SELECT idundergraduate FROM undergraduate WHERE idstudent=?)" +
					"RETURNING idundergraduate";
			pstmt1 = conn.prepareStatement(sql1);
			pstmt1.setString(1, college);
			pstmt1.setInt(2, pid);
			pstmt1.setInt(3, pid);
			if (pstmt1.execute())
			{
				ResultSet rs1 = pstmt1.getResultSet();
				if (rs1.next()){
					idundergrdauate = rs1.getInt("idundergraduate");
				}
				else {
					throw new SQLException("That student is already registered as an undergrad.");
				}
			}
			else
			{
				throw new SQLException("Insert into undergraduate failed.");
			}
			
			/* Insert major and minor table only if inserted into undergraduate table successfully */
			if(idundergrdauate>0){
				
				/* insert major */
				sql2 = "INSERT INTO undergraduate_degree__major(idundergraduate, iddegree)" + 
						"SELECT ?,?" +
						"WHERE NOT EXISTS (SELECT idundergraduate_degree__major FROM undergraduate_degree__major WHERE idundergraduate=?)" +
						"RETURNING idundergraduate_degree__major";
				pstmt2 = conn.prepareStatement(sql2);
				pstmt2.setInt(1, idundergrdauate);
				pstmt2.setInt(2, major);
				pstmt2.setInt(3, idundergrdauate);
				if (pstmt2.execute())
				{
					ResultSet rs2 = pstmt2.getResultSet();
					if (rs2.next()){
						if(rs2.getInt("idundergraduate_degree__major") > 0)
							success = true;
					}
				}
				else
				{
					throw new SQLException("Insert into previousdegree failed.");
				}
				
				/* insert minor only if chosen */
				if (minor!=0) {
					success = false;
					sql3 = "INSERT INTO undergraduate_degree__minor(idundergraduate, iddegree)" + 
							"SELECT ?,?" +
							"WHERE NOT EXISTS (SELECT idundergraduate_degree__minor FROM undergraduate_degree__minor WHERE idundergraduate=?)" +
							"RETURNING idundergraduate_degree__minor";
					pstmt3 = conn.prepareStatement(sql3);
					pstmt3.setInt(1, idundergrdauate);
					pstmt3.setInt(2, minor);
					pstmt3.setInt(3, idundergrdauate);
					if (pstmt3.execute())
					{
						ResultSet rs3 = pstmt3.getResultSet();
						if (rs3.next()){
							if(rs3.getInt("idundergraduate_degree__minor") > 0)
								success = true;
						}
					}
					else
					{
						throw new SQLException("Insert into previousdegree failed.");
					}
				}
				
			}
			
		}
		else {
			throw new SQLException("MAJOR AND MINOR MUST BE DIFFERENT.");
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
		String message = "Successfully registered student as undergraduate student";
		%>
		<h1><%=message %></h1>
		<%
	}
}


/* =========================== */
/* Generate Form Fields Action */
/* =========================== */

ResultSet major_rs = null;
ResultSet minor_rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	PreparedStatement stmt1 = conn.prepareStatement("SELECT * FROM degree");
	PreparedStatement stmt2 = conn.prepareStatement("SELECT * FROM degree");
	/* The below statement is not closed, this might cause issues later... */
	major_rs = stmt1.executeQuery();
	minor_rs = stmt2.executeQuery(); 
	
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

	<h2>Undergraduate Entry Form</h2>
	
	<!-- Student Insertion Form -->
	<form action="undergraduate_entry_form.jsp" method="POST">
		
		<div>
			PID: <input type="text" name="pid" required>
			<br>
		</div>
		<p>
		
		<div>
			Major:
			<select name="major">
				<%
				if (major_rs.isBeforeFirst())
				{
					while(major_rs.next()){
						%>
						<option value=<%=major_rs.getString("iddegree")%>><%=major_rs.getString("name")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		
		<div>
			Minor:
			<select name="minor">
				<option value="0">None</option>
				<%
				if (minor_rs.isBeforeFirst())
				{
					while(minor_rs.next()){
						%>
						<option value=<%=minor_rs.getString("iddegree")%>><%=minor_rs.getString("name")%></option>
						<%
					}
				}
				%>
			</select>
		</div>
		<p>
		(Please keep in mind that Major and Minor cannot be the same)
		<p>

		<div>
			College: 
			<br>
			<input type="radio" name="college" value="revelle" checked>Revelle College<br>
			<input type="radio" name="college" value="muir" >Muir College<br>
			<input type="radio" name="college" value="marshall" >Marshall College<br>
			<input type="radio" name="college" value="warren" >Warren College<br>
			<input type="radio" name="college" value="erc" >Eleanor Roosevelt College<br>
			<input type="radio" name="college" value="sixth" >Sixth College<br>
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