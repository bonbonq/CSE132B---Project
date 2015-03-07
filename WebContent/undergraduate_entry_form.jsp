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
					"AND EXISTS (SELECT idstudent FROM student WHERE idstudent=?) "+
					"AND NOT EXISTS (SELECT idms FROM ms WHERE idstudent=?)" +
					"AND NOT EXISTS (SELECT idcandidate FROM candidate WHERE idstudent=?)" +
					"AND NOT EXISTS (SELECT idprecandidate FROM precandidate WHERE idstudent=?)" +
					"RETURNING idundergraduate";
			pstmt1 = conn.prepareStatement(sql1);
			pstmt1.setString(1, college);
			pstmt1.setInt(2, pid);
			pstmt1.setInt(3, pid);
			pstmt1.setInt(4, pid);
			pstmt1.setInt(5, pid);
			pstmt1.setInt(6, pid);
			pstmt1.setInt(7, pid);
			if (pstmt1.execute())
			{
				ResultSet rs1 = pstmt1.getResultSet();
				if (rs1.next()){
					idundergrdauate = rs1.getInt("idundergraduate");
				}
				else {
					throw new SQLException("That student is already registeredor the student doesn't exist.");
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

/* ============= */
/* Update Action */
/* ============= */
else if(action!=null && action.equals("undergrad_update")){
	
	PreparedStatement update = conn.prepareStatement(	
			"Update undergraduate SET " +
			"college=? " +
			"WHERE idundergraduate=?");
	update.setString(1, request.getParameter("college"));
	update.setInt(2, Integer.parseInt(request.getParameter("idundergraduate")));
	
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

else if(action!=null && action.equals("major_update")){
	
	PreparedStatement update = conn.prepareStatement(	
			"Update undergraduate_degree__major SET " +
			"iddegree=? " +
			"WHERE idundergraduate_degree__major=?");
	update.setInt(1, Integer.parseInt(request.getParameter("iddegree")));
	update.setInt(2, Integer.parseInt(request.getParameter("idundergraduate_degree__major")));
	
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
else if(action!=null && action.equals("minor_update")){
	
	PreparedStatement update = conn.prepareStatement(	
			"Update undergraduate_degree__minor SET " +
			"iddegree=? " +
			"WHERE idundergraduate_degree__minor=?");
	update.setInt(1, Integer.parseInt(request.getParameter("iddegree")));
	update.setInt(2, Integer.parseInt(request.getParameter("idundergraduate_degree__minor")));
	
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

else if(action!=null && action.equals("minor_add_update")){
	
	PreparedStatement update = conn.prepareStatement(	
			"Update undergraduate_degree__minor SET " +
			"iddegree=? " +
			"WHERE NOT EXISTS (" +
				"SELECT * FROM undergraduate_degree__minor WHERE idundergraduate=?" +
			") RETURNING undergraduate_degree__minor");
	update.setInt(1, Integer.parseInt(request.getParameter("iddegree")));
	update.setInt(2, Integer.parseInt(request.getParameter("idundergraduate")));
	System.out.println("test");
	if(update.execute()){
		if (update.getResultSet().next()){
			%>
			<h1>Successfully Updated!</h1>
			<%
		}
		else {
			%>
			<h1>Undergraduate student already has a minor. Please use update function below.</h1>
			<%
		}
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

else if(action!=null && (action.equals("undergrad_delete") || action.equals("major_delete") || action.equals("minor_delete"))) {

	String table_name;
	String table_id;
	String id_parameter_name;
	
	if (action.equals("undergrad_delete")) {
		table_name = "undergraduate";
		table_id = "idundergraduate";
		id_parameter_name = "idundergraduate";
	}
	
	else if (action.equals("major_delete")) {
		table_name = "undergraduate_degree__major";
		table_id = "idundergraduate_degree__major";
		id_parameter_name = "idundergraduate_degree__major";
	}
	else { /* action.equals("minor_delete")) */
		table_name = "undergraduate_degree__minor";
		table_id = "idundergraduate_degree__minor";
		id_parameter_name = "idundergraduate_degree__minor";
	}
	
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

ResultSet major_rs = null;
ResultSet minor_rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	PreparedStatement stmt1 = conn.prepareStatement("SELECT * FROM degree", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	PreparedStatement stmt2 = conn.prepareStatement("SELECT * FROM degree", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
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

/* ========================= */
/* EDIT FORM DATA GENERATION */
/* ========================= */

ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	/* The below statements are not closed, this might cause issues later... */
	rs1 = conn.prepareStatement("SELECT * FROM undergraduate NATURAL JOIN student NATURAL JOIN (undergraduate_degree__major NATURAL JOIN degree) ORDER BY idstudent").executeQuery();
	rs2 = conn.prepareStatement("SELECT * FROM undergraduate NATURAL JOIN student NATURAL JOIN (undergraduate_degree__minor NATURAL JOIN degree) ORDER BY idstudent").executeQuery();
	rs3 = conn.prepareStatement("SELECT * FROM undergraduate NATURAL JOIN student ORDER BY idstudent", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE).executeQuery();
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
	
	<br>
	<br>
	
	<!-- Edit Form -->
	<h2>Undergraduate General Info Edit Form</h2>
	
	<table>
	  <tr>
	    <th>PID - Name</th>
	    <th>College</th>
	    <th>Edit Actions</th>
	  </tr>
	  <%
		if (rs3.isBeforeFirst()) {
			while(rs3.next()) { 
			%>
				<form action="undergraduate_entry_form.jsp" method="POST">
					<input type="hidden" name="idundergraduate" value="<%=rs3.getString("idundergraduate") %>">
		  			<tr>
					    <td><%=rs3.getString("idstudent") %> - <%=rs3.getString("first_name") %> <%=rs3.getString("last_name") %></td>
					    
					    <td>
							<table>
								<tr>
									<td>
										&nbsp;
										<input type="radio" name="college" value="revelle" <%= rs3.getString("college").equals("revelle") ? "checked" : "" %>  >Revelle College<br>&nbsp;
										<input type="radio" name="college" value="muir" <%= rs3.getString("college").equals("muir") ? "checked" : "" %>  >Muir College<br>&nbsp;
										<input type="radio" name="college" value="marshall" <%= rs3.getString("college").equals("marshall") ? "checked" : "" %>  >Marshall College<br>&nbsp;
									</td>
									<td>
										&nbsp;
										<input type="radio" name="college" value="warren" <%= rs3.getString("college").equals("warren") ? "checked" : "" %>  >Warren College<br>&nbsp;
										<input type="radio" name="college" value="erc" <%= rs3.getString("college").equals("erc") ? "checked" : "" %>  >Eleanor Roosevelt College<br>&nbsp;
										<input type="radio" name="college" value="sixth" <%= rs3.getString("college").equals("sixth") ? "checked" : "" %>  >Sixth College<br>&nbsp;
									</td>
								</tr>
							</table>
							&nbsp;
						</td>
					    
					    <td>
							&nbsp;
							<button type="submit" name="action" value="undergrad_update">Update</button>
							&nbsp;
							<button type="submit" name="action" value="undergrad_delete">Delete</button>
						</td>
					</tr>
			 	</form>
					
			<%
			}
		}
	  %>
	</table>
	
	
	<h2>Major Edit Form</h2>
	
	<table>
	  <tr>
	    <th>PID - Name</th>
	    <th>Major</th>
	    <th>Edit Actions</th>
	  </tr>
	  <%
		if (rs1.isBeforeFirst()) {
			while(rs1.next()) { 
			%>
				<form action="undergraduate_entry_form.jsp" method="POST">
					<input type="hidden" name="idundergraduate_degree__major" value="<%=rs1.getString("idundergraduate_degree__major") %>">
		  			<tr>
					    <td><%=rs1.getString("idstudent") %> - <%=rs1.getString("first_name") %> <%=rs1.getString("last_name") %></td>
					    
					    <td>
					    	&nbsp;
					    	<select name="iddegree">
								<%
								major_rs.beforeFirst();
								if (major_rs.isBeforeFirst())
								{
									while(major_rs.next()){
										%>
										<option value=<%=major_rs.getString("iddegree")%>  <%= rs1.getString("iddegree").equals(major_rs.getString("iddegree")) ? "selected" : ""%>  ><%=major_rs.getString("name")%></option>
										<%
									}
								}
								%>
							</select>
					    </td>
					    
					    <td>
							&nbsp;
							<button type="submit" name="action" value="major_update">Update</button>
							&nbsp;
							<!-- <button type="submit" name="action" value="major_delete">Delete</button> -->
						</td>
					</tr>
			 	</form>
					
			<%
			}
		}
	  %>
	</table>
	
	
	<h2>Minor Edit Form</h2>
	
	<table>
	  <tr>
	    <th>PID - Name</th>
	    <th>Minor</th>
	    <th>Edit Actions</th>
	  </tr>
	  
	  <!-- Add new minor for existing undergrad -->
		<form action="undergraduate_entry_form.jsp" method="POST">
			<tr>
				<td>
					&nbsp;
					<select name="idundergraduate">
					<%
						rs3.beforeFirst();
						if (rs3.isBeforeFirst())
						{
							while(rs3.next()){
							%>
								<option value=<%=rs3.getString("idundergraduate")%>  > <%=rs3.getString("idstudent")%> - <%=rs3.getString("first_name")%> <%=rs3.getString("last_name")%></option>
							<%
							}
						}
					%>
					</select>
				</td>
			
				<td>
					&nbsp;
					<select name="iddegree">
						<option value="0">None</option>
						<%
							minor_rs.beforeFirst();
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
				</td>
				  
				<td>
					&nbsp;
					<button type="submit" name="action" value="minor_add_update">Add Minor</button>
				</td>
				
			</tr>
		</form>
	  
	  <!-- Edit Portion -->
	  <%
		if (rs2.isBeforeFirst()) {
			while(rs2.next()) { 
			%>
				<form action="undergraduate_entry_form.jsp" method="POST">
					<input type="hidden" name="idundergraduate_degree__minor" value="<%=rs2.getString("idundergraduate_degree__minor") %>">
		  			<tr>
					    <td><%=rs2.getString("idstudent") %> - <%=rs2.getString("first_name") %> <%=rs2.getString("last_name") %></td>
					    
					    <td>
					    	&nbsp;
					    	<select name="iddegree">
								<%
								minor_rs.beforeFirst();
								if (minor_rs.isBeforeFirst())
								{
									while(minor_rs.next()){
										%>
										<option value=<%=minor_rs.getString("iddegree")%>  <%= rs2.getString("iddegree").equals(minor_rs.getString("iddegree")) ? "selected" : "" %>  ><%=minor_rs.getString("name")%></option>
										<%
									}
								}
								%>
							</select>
					    </td>
					    
					    <td>
							&nbsp;
							<button type="submit" name="action" value="minor_update">Update</button>
							&nbsp;
							<button type="submit" name="action" value="minor_delete">Delete</button>
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