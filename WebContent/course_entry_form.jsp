<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Course Entry Form</title>
</head>

<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page import="java.sql.*" %>
<%@page import="org.postgresql.*" %>

<!-- Java Part start -->
<%
boolean debug = false;

boolean success = false;
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

/* Create DB connection */
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
int department = 0;
String course_number;
String[] prereqs;
boolean consent_prereq = false;
int min_units;
int max_units;
String grade_type;
boolean lab = false;

if (debug)
	System.out.println("action: "+action);

ResultSet department_rs = null;
ResultSet prereq_rs = null;

/* Insert Action */
if (action!=null && action.equals("insert")) {
	
	course_number = request.getParameter("course_number");
	department = Integer.parseInt(request.getParameter("department"));
	prereqs = request.getParameterValues("prereq");
	min_units = Integer.parseInt(request.getParameter("min_units"));
	max_units = Integer.parseInt(request.getParameter("max_units"));
	grade_type = request.getParameter("grade_type");
	if(request.getParameter("lab").equals("True")){
		lab = true;	
	}
	if(prereqs!=null){
		for(String prereq : prereqs)
		{
			if(prereq.equals("0"))
				consent_prereq = true;
		}
	}
	
	/* Print statements for parameters */
	if (debug){
		
		System.out.println("Department: " + department);
		System.out.println("Course Number: " + course_number);
		System.out.print("Prereq: ");
		if (prereqs!=null){
			for(String prereq : prereqs)
			{
				System.out.print(prereq + ", ");
			}
			System.out.println("");
		}
		else{
			System.out.println("none");
		}
		System.out.println("Unit range: " + min_units + " - " + max_units);
		System.out.println("Grade Type: " + grade_type);
		System.out.println("Lab? " + lab);	
		
	}
	
	if(department!=0 && course_number!=null && max_units >= min_units && grade_type!=null) {
		try{
			// Create the statement
			conn.setAutoCommit(false);
			// Insert the user into table users, only if it does not already exist
			sql1 =	"INSERT INTO course (grade_option_type, min_units, max_units, lab, consent_prereq)"+
					"SELECT ?,?,?,?,?" + 
					"WHERE NOT EXISTS (" +
						"SELECT idcoursenumber FROM coursenumber WHERE number=?" +
					") " +
					"RETURNING idcourse " +
					";" ;	
			pstmt1 = conn.prepareStatement(sql1);
			pstmt1.setString(1, grade_type);
			pstmt1.setInt(2, min_units);
			pstmt1.setInt(3, max_units);
			pstmt1.setBoolean(4, lab);
			pstmt1.setBoolean(5, consent_prereq);
			pstmt1.setString(6, course_number);
			
			sql2 =	"INSERT INTO coursenumber (number)" +
					"SELECT ?" +
					"WHERE NOT EXISTS (" +
						"SELECT idcoursenumber FROM coursenumber WHERE number=?" +
					") RETURNING idcoursenumber" +
					";" ;
			pstmt2 = conn.prepareStatement(sql2);
			pstmt2.setString(1, course_number);
			pstmt2.setString(2, course_number);

			/* execute and retrieve the idcourse and idcoursenumber of the latest inserted course */
			int idcourse = 0;
			if (pstmt1.execute())
			{
				ResultSet rs1 = pstmt1.getResultSet();
				if (rs1.next()){
					idcourse = rs1.getInt("idcourse");
				}
			}
			else
			{
				conn.rollback();
				throw new SQLException("Insert into course failed.");
			} 
			
			int idcoursenumber = 0;
			if (pstmt2.execute())
			{
				ResultSet rs2 = pstmt2.getResultSet();
				if (rs2.next()){
					idcoursenumber = rs2.getInt("idcoursenumber");
				}
			}
			else
			{
				conn.rollback();
				throw new SQLException("Insert into coursenumber failed.");
			}
			
			/* insert relationship into course_coursenumber */
			if(idcourse!=0 && idcoursenumber!=0){
				sql3 = "INSERT INTO course_coursenumber (idcourse, idcoursenumber) " +
						"SELECT ?,? " +
						"RETURNING idcourse_coursenumber" +
						";";
				pstmt3 = conn.prepareStatement(sql3);
				pstmt3.setInt(1, idcourse);
				pstmt3.setInt(2, idcoursenumber);
				if (pstmt3.execute())
				{
					ResultSet rs3 = pstmt3.getResultSet();
					if (rs3.next()){
						System.out.println("idcourse_coursenumber: " + rs3.getInt("idcourse_coursenumber"));
					}
				}
			}
			else if (idcourse==0 && idcoursenumber==0) {
				conn.rollback();
				throw new SQLException("That course number is taken, please choose another unique course number or update it.");
			}
			else
			{
				conn.rollback();
				throw new SQLException("Insert into course_coursenumber failed: "+idcourse + "," + idcoursenumber);
			}
			
			/* insert  prereqs relationship */
			if(idcourse!=0 && idcoursenumber!=0){
				if(prereqs!=null){
					for(String prereq : prereqs){
						int prereq_num = Integer.parseInt(prereq);
						if (prereq_num!=0){
							sql4 = "INSERT INTO prereqs (idcourse, prereq_idcourse)" +
									"SELECT ?,? " +
									"WHERE NOT EXISTS (" +
										"SELECT idprereqs FROM prereqs WHERE idcourse=? AND prereq_idcourse=?" +
									") RETURNING idprereqs" + 
									";";
							pstmt4 = conn.prepareStatement(sql4);
							pstmt4.setInt(1, idcourse);
							pstmt4.setInt(2, prereq_num);
							pstmt4.setInt(3, idcourse);
							pstmt4.setInt(4, prereq_num);
							System.out.println(pstmt4);
							if (pstmt4.execute())
							{
								ResultSet rs4 = pstmt4.getResultSet();
								if (rs4.next()){
									System.out.println("idprereqs: " + rs4.getInt("idprereqs"));
								}
							}
						}
					}
				}
			}
			else
			{
				conn.rollback();
				throw new SQLException("Insert into course_coursenumber failed: "+idcourse + "," + idcoursenumber);
			} 
			
			/* insert  department_course relationship */
			if(idcourse!=0 && idcoursenumber!=0){
				sql5 = "INSERT INTO department_course (iddepartment, idcourse) " +
						"SELECT ?,? " +
						"WHERE NOT EXISTS (" +
							"SELECT iddepartment_course FROM department_course WHERE iddepartment=? AND idcourse=? " +
						") RETURNING iddepartment_course" + 
						";";
				pstmt5 = conn.prepareStatement(sql5);
				pstmt5.setInt(1, department);
				pstmt5.setInt(2, idcourse);
				pstmt5.setInt(3, department);
				pstmt5.setInt(4, idcourse);
				if (pstmt5.execute())
				{
					ResultSet rs5 = pstmt5.getResultSet();
					if (rs5.next()){
						System.out.println("iddepartment_course: " + rs5.getInt("iddepartment_course"));
					}
				}
				
			}
			else
			{
				conn.rollback();
				throw new SQLException("Insert into course_coursenumber failed: "+idcourse + "," + idcoursenumber);
			} 
			
			conn.commit();
			conn.setAutoCommit(true);
			success = true;
					
		} catch (SQLException e) {
			conn.rollback();
			e.printStackTrace();
            String message = "Failure: Your entry failed " + e.getMessage();
		   	%>
			<h1><%=message %></h1>
			<%
		}
		finally
		{
			if (pstmt1 != null)
				pstmt1.close();
			if (pstmt2 != null)
				pstmt2.close();
			if (pstmt3 != null)
				pstmt3.close();
			if (pstmt4 != null)
				pstmt4.close();
			if (pstmt5 != null)
				pstmt5.close();
		}
		
	/* else will happen if parameters are not correct */
	}
	else {
		String message = "Please enter valid form entries.";
		%>
		<h1><%=message %></h1>
		<%
	}
	
	if (success) {
		String message = "Successfully added new course.";
		%>
		<h1><%=message %></h1>
		<%
	}
        
}

/* ============= */
/* Update Action */
/* ============= */
else if(action!=null && action.equals("course_update")){
	
	PreparedStatement update = conn.prepareStatement(	
			"Update course SET " +
			"grade_option_type = ?, min_units=?, max_units=?, lab=?, consent_prereq=? " +
			"WHERE idcourse=?");
	update.setString(1, request.getParameter("grade_option_type"));
	update.setInt(2, Integer.parseInt(request.getParameter("min_units")));
	update.setInt(3, Integer.parseInt(request.getParameter("max_units")));
	update.setBoolean(4, request.getParameter("lab").equals("True") ? true : false);
	update.setBoolean(5, request.getParameter("consent_prereq").equals("True") ? true : false);
	update.setInt(6, Integer.parseInt(request.getParameter("idcourse")));
	
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

else if(action!=null && action.equals("coursenumber_update")){
	
	PreparedStatement update = conn.prepareStatement(	
			"UPDATE coursenumber SET " +
			"number = ? " +
			"WHERE idcoursenumber=?");
	update.setString(1, request.getParameter("number"));
	update.setInt(2, Integer.parseInt(request.getParameter("idcoursenumber")));

	try {
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
	} catch (SQLException e) {
		String message = "Failure: Your entry failed " + e.getMessage();
	   	%>
		<h1><%=message %></h1>
		<%
	}
}

else if(action!=null && action.equals("coursenumber_add_update")){
	
	PreparedStatement update = conn.prepareStatement(	
			"INSERT INTO coursenumber (number) SELECT ?");
	update.setString(1, request.getParameter("number"));
	
	try {
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
	} catch (SQLException e) {
		String message = "Failure: Your entry failed " + e.getMessage();
	   	%>
		<h1><%=message %></h1>
		<%
	}
}

else if(action!=null && action.equals("course_coursenumber_update")){
	
	PreparedStatement update = conn.prepareStatement(	
			"Update course_coursenumber SET " +
			"idcoursenumber=? " +
			"WHERE idcourse_coursenumber=?");
	update.setInt(1, Integer.parseInt(request.getParameter("idcoursenumber")));
	update.setInt(2, Integer.parseInt(request.getParameter("idcourse_coursenumber")));
	
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

else if(action!=null && action.equals("course_coursenumber_add_update")){
	
	if(request.getParameter("idcourse")!=null && request.getParameter("idcoursenumber")!=null) {
		PreparedStatement update = conn.prepareStatement(	
				"INSERT INTO course_coursenumber(idcourse, idcoursenumber) " +
				"SELECT ?,? " +
				"WHERE NOT EXISTS (SELECT * FROM course_coursenumber WHERE idcourse=? AND idcoursenumber=?)");
		update.setInt(1, Integer.parseInt(request.getParameter("idcourse")));
		update.setInt(2, Integer.parseInt(request.getParameter("idcoursenumber")));
		update.setInt(3, Integer.parseInt(request.getParameter("idcourse")));
		update.setInt(4, Integer.parseInt(request.getParameter("idcoursenumber")));
		
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

}

else if(action!=null && action.equals("departmentcourse_update")){
	
	PreparedStatement update = conn.prepareStatement(	
			"Update department_course SET " +
			"iddepartment = ? " +
			"WHERE iddepartment_course=?");
	update.setInt(1, Integer.parseInt(request.getParameter("iddepartment")));
	update.setInt(2, Integer.parseInt(request.getParameter("iddepartment_course")));
	
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

else if(action!=null && (action.equals("course_delete") || action.equals("coursenumber_delete"))) {

	String table_name = "";
	String table_id = "";
	String id_parameter_name = "";
	
	if (action.equals("course_delete")){
		table_name = "course";
		table_id = "idcourse";
		id_parameter_name = "idcourse";
	}
	else if (action.equals("coursenumber_delete")){
		table_name = "coursenumber";
		table_id = "idcoursenumber";
		id_parameter_name = "idcoursenumber";
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
// The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	PreparedStatement dept_stmt = conn.prepareStatement("SELECT * FROM department", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	PreparedStatement prereq_stmt = conn.prepareStatement("SELECT DISTINCT idcourse,number FROM course NATURAL JOIN course_coursenumber NATURAL JOIN coursenumber", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	/* The below two statements are not closed, this might cause issues later... */
	department_rs = dept_stmt.executeQuery();
	prereq_rs = prereq_stmt.executeQuery();
	
	conn.commit();
	conn.setAutoCommit(true);
	
} catch(SQLException e) {
	conn.rollback();
	e.printStackTrace();
    String message = "Failure: Your entry failed " + e.getMessage();
   	%>
	<h1><%=message %></h1>
	<%
} 


/* ========================= */
/* EDIT FORM DATA GENERATION */
/* ========================= */

ResultSet course_rs = null;
ResultSet coursenumber_rs = null;
ResultSet course_coursenumber_rs = null;
ResultSet unmatched_rs = null;
ResultSet departmentcourse_rs = null;

//The following will always run regardless of action
try{
	conn.setAutoCommit(false);
	
	/* The below statements are not closed, this might cause issues later... */
	course_rs = conn.prepareStatement("SELECT * FROM course ORDER BY idcourse", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE).executeQuery();
	coursenumber_rs = conn.prepareStatement("SELECT * FROM coursenumber ORDER BY idcoursenumber", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE).executeQuery();
	course_coursenumber_rs = conn.prepareStatement("SELECT * FROM course_coursenumber NATURAL JOIN course NATURAL JOIN coursenumber ORDER BY idcourse", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE).executeQuery();
	unmatched_rs = conn.prepareStatement("SELECT idcourse FROM course WHERE idcourse NOT IN (SELECT idcourse FROM course_coursenumber)", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE).executeQuery();	
	departmentcourse_rs = conn.prepareStatement("SELECT iddepartment_course, idcourse, number, iddepartment, name FROM course NATURAL JOIN course_coursenumber NATURAL JOIN coursenumber NATURAL JOIN department NATURAL JOIN department_course ORDER BY idcourse", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE).executeQuery();	

	
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




<!-- HTML Body Start -->
<body>

	<a href='index.jsp'><button>Home</button></a>
	<h2>Course Entry Form</h2>

	<!-- Course Insertion Form -->
	<form action="course_entry_form.jsp" method="POST">
	
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
		
		<div class="form-group">
			Unique Course Number: (ex. CSE132) 
			<br>
			<input type="text" name="course_number" required>
		</div>
		<p>
		
		<div class="form-group">
			Prerequisite courses:
			<br>
			<input type="checkbox" name="prereq" value=0> Consent of Instructor
			<%
			if (prereq_rs.isBeforeFirst())
			{
				while(prereq_rs.next()){
					%>
					<br>
					<input type="checkbox" name="prereq" value=<%=prereq_rs.getInt("idcourse")%>> <%=prereq_rs.getString("number")%>
					<%
				}
			}
			%>
			<br>
		</div>	
		<p>
		
		<div class="form-group">
			Minimum Units: <input type="number" name="min_units" min="0" required>
			<br>
			Maximum Units: <input type="number" name="max_units" min="0" required>
			<br>
		</div>
		<p>
		
		<div class="form-group">
			Grade Option(s) Accepted:
			<br>
			<input type="radio" name="grade_type" value="letter" checked>Letter Grade
			<br>
			<input type="radio" name="grade_type" value="s_u">S/U
			<br>
			<input type="radio" name="grade_type" value="both">Letter Grade and S/U
			<br>
		</div>
		<p>
		
		<div class="form-group">
			Lab work required?
			<br>
			<input type="radio" name="lab" value="True">Yes
			<br>
			<input type="radio" name="lab" value="False" checked>No
		</div>
		<p>
		
		<button type="submit" name="action" value="insert">Submit</button>
		
	</form>

	<br>
	<br>
	
	<!-- Edit Form -->
	<h2>Course Edit Form</h2>
	
	<table>
	  <tr>
	    <th>Course ID - Name</th>
	    <th>Grade Option Type</th>
	    <th>Min Units</th>
	    <th>Max Units</th>
	    <th>Lab?</th>
	    <th>Consent Prereq?</th>
	    <th>Edit Actions</th>
	  </tr>
	  <%
		if (course_rs.isBeforeFirst()) {
			while(course_rs.next()) { 
			%>
				<form action="course_entry_form.jsp" method="POST">
					<input type="hidden" name="idcourse" value="<%=course_rs.getString("idcourse") %>">
		  			<tr>
		  				<td><%=course_rs.getString("idcourse") %></td>
					    <td>
					    	<br>
							<input type="radio" name="grade_option_type" value="letter" <%=course_rs.getString("grade_option_type").equals("letter") ? "checked" : ""  %>  >Letter Grade
							<br>
							<input type="radio" name="grade_option_type" value="s_u" <%=course_rs.getString("grade_option_type").equals("s_u") ? "checked" : ""  %>  >S/U
							<br>
							<input type="radio" name="grade_option_type" value="both" <%=course_rs.getString("grade_option_type").equals("both") ? "checked" : ""  %>  >Letter Grade and S/U
							<br>
					    </td>
					    <td><input type="number" name="min_units" value="<%=course_rs.getString("min_units") %>" required></td>
					    <td><input type="number" name="max_units" value="<%=course_rs.getString("max_units") %>" required></td>
					    <td>
					    	<br>
							<input type="radio" name="lab" value="True"  <%=course_rs.getString("lab").trim().equals("t") ? "checked" : ""  %>  >Yes
							<br>
							<input type="radio" name="lab" value="False" <%=course_rs.getString("lab").trim().equals("f") ? "checked" : ""  %>  >No
							<br>
					    </td>
					    <td>
					    	<br>
							&nbsp;&nbsp;&nbsp;
							<input type="radio" name="consent_prereq" value="True"  <%=course_rs.getString("consent_prereq").trim().equals("t") ? "checked" : ""  %>  >Yes
							<br>
							&nbsp;&nbsp;&nbsp;
							<input type="radio" name="consent_prereq" value="False" <%=course_rs.getString("consent_prereq").trim().equals("f") ? "checked" : ""  %>  >No
							<br>
					    </td>
					    <td>
							&nbsp;
							<button type="submit" name="action" value="course_update">Update</button>
							&nbsp;
							<button type="submit" name="action" value="course_delete">Delete</button>
						</td>
					</tr>
			 	</form>
					
			<%
			}
		}
	  %>
	</table>
	
	<br>
	<br>
	<!-- Edit Form -->
	<h2>Course Number Edit Form</h2>
	<form action="course_entry_form.jsp" method="POST">
		<input type="text" name="number" required>
		<button type="submit" name="action" value="coursenumber_add_update">Add New Course Number</button>
	</form>
	<p>
	<table>
	  <tr>
	    <th>Coursenumber ID</th>
	    <th>Name</th>
	    <th>Edit Actions</th>
	  </tr>
	  <%
		if (coursenumber_rs.isBeforeFirst()) {
			while(coursenumber_rs.next()) { 
			%>
				<form action="course_entry_form.jsp" method="POST">
					<input type="hidden" name="idcoursenumber" value="<%=coursenumber_rs.getString("idcoursenumber") %>">
		  			<tr>
					    <td><%=coursenumber_rs.getString("idcoursenumber") %></td>
					    <td><input type="text" name="number" value="<%=coursenumber_rs.getString("number") %>" required></td>
					    <td>
							&nbsp;
							<button type="submit" name="action" value="coursenumber_update">Update</button>
							&nbsp;
							<button type="submit" name="action" value="coursenumber_delete">Delete</button>
						</td>
					</tr>
			 	</form>
					
			<%
			}
		}
	  %>
	</table>
	
	<br>
	<br>
	<!-- Edit Form -->
	<h2>Change Course Name Form</h2>
	
	<form action="course_entry_form.jsp" method="POST">
		Course ID: 
		<select name="idcourse">
    		<%
	    	unmatched_rs.beforeFirst();
			if (unmatched_rs.isBeforeFirst())
			{
				while(unmatched_rs.next()){
					String idcourse = unmatched_rs.getString("idcourse");
					%>
					<option value=<%=idcourse%>><%=idcourse%></option>
					<%
				}
			}
			%>
    	</select>
    	Course Number: 
		<select name="idcoursenumber">
    		<%
	    	coursenumber_rs.beforeFirst();
			if (coursenumber_rs.isBeforeFirst())
			{
				while(coursenumber_rs.next()){
					%>
					<option value=<%=coursenumber_rs.getString("idcoursenumber")%>><%=coursenumber_rs.getString("number")%></option>
					<%
				}
			}
			%>
    	</select>
    	<button type="submit" name="action" value="course_coursenumber_add_update">Update</button>
	</form>
	<p>
	<table>
	  <tr>
	    <th>Course ID&nbsp;&nbsp;</th>
	    <th>Course Number&nbsp;</th>
	    <th>Edit Actions</th>
	  </tr>
	  <%
		if (course_coursenumber_rs.isBeforeFirst()) {
			while(course_coursenumber_rs.next()) { 
			%>
				<form action="course_entry_form.jsp" method="POST">
					<input type="hidden" name="idcourse_coursenumber" value="<%=course_coursenumber_rs.getString("idcourse_coursenumber") %>">
		  			<tr>
					    <td><%=course_coursenumber_rs.getString("idcourse") %></td>
					    <td>
					    	<select name="idcoursenumber">
					    		<%
						    	coursenumber_rs.beforeFirst();
								if (coursenumber_rs.isBeforeFirst())
								{
									while(coursenumber_rs.next()){
										String idcoursenumber = coursenumber_rs.getString("idcoursenumber");
										%>
										<option value=<%=idcoursenumber%>  <%=course_coursenumber_rs.getString("idcoursenumber").equals(idcoursenumber) ? "selected" : ""  %>><%=coursenumber_rs.getString("number")%></option>
										<%
									}
								}
								%>
					    	</select>
					    </td>
					    <td>
							&nbsp;
							<button type="submit" name="action" value="course_coursenumber_update">Update</button>
							&nbsp;
							<!-- <button type="submit" name="action" value="course_coursenumber_delete">Delete</button> -->
						</td>
					</tr>
			 	</form>
					
			<%
			}
		}
	  %>
	</table>

	<br>
	<br>
	<!-- Course Department Edit Form -->
	<h2>Course Department Edit Form</h2>
	
	<table>
	  <tr>
	    <th>Course Name</th>
	    <th>Department</th>
	    <th>Edit Actions</th>
	  </tr>
	  <%
		if (departmentcourse_rs.isBeforeFirst()) {
			while(departmentcourse_rs.next()) { 
			%>
				<form action="course_entry_form.jsp" method="POST">
					<input type="hidden" name="iddepartment_course" value="<%= departmentcourse_rs.getString("iddepartment_course") %>">
		  			<tr>
					    <td><%= departmentcourse_rs.getString("number") %></td>
					    <td>
					    	<select name="iddepartment">
								<%
								department_rs.beforeFirst();
								if (department_rs.isBeforeFirst())
								{
									while(department_rs.next()){
										%>
										<option value=<%=department_rs.getString("iddepartment")%>  <%= departmentcourse_rs.getString("iddepartment").equals(department_rs.getString("iddepartment")) ? "selected" : "" %>>  <%=department_rs.getString("name")%></option>
										<%
									}
								}
								%>
							</select>
					    </td>
					    <td>
							&nbsp;
							<button type="submit" name="action" value="departmentcourse_update">Update</button>
							&nbsp;
							<!-- <button type="submit" name="action" value="delete">Delete</button> -->
						</td>
					</tr>
			 	</form>
					
			<%
			}
		}
	  %>
	</table>
	
	<br>
	<br>
	<!-- Prereq Edit Form -->
	<h2>Prereq Edit Form</h2>
	<form action="edit_prereq_form.jsp" method="POST">
		Choose Course: 
		<select name="idcourse">
	   		<%
	   		departmentcourse_rs.beforeFirst();
			if (departmentcourse_rs.isBeforeFirst())
			{
				while(departmentcourse_rs.next()){
					%>
					<option value=<%=departmentcourse_rs.getString("idcourse")%>><%=departmentcourse_rs.getString("number")%></option>
					<%
				}
			}
			%>
	   	</select>
		<button type="submit" name="action" value="course_entry_form">Edit Prereqs</button>
	</form>
	
</body>
<!-- HTML Body End -->

<%

if (conn != null)
	conn.close();
%>

</html>