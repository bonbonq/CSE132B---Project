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
boolean debug = true;
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


/* Generate Form Fields Action */

try{
	conn.setAutoCommit(false);
	PreparedStatement dept_stmt = conn.prepareStatement("SELECT * FROM department");
	PreparedStatement prereq_stmt = conn.prepareStatement("SELECT DISTINCT idcourse,number FROM course NATURAL JOIN course_coursenumber NATURAL JOIN coursenumber");
	/* The below two statements are not closed, this might cause issues later... */
	department_rs = dept_stmt.executeQuery();
	prereq_rs = prereq_stmt.executeQuery();
	
	conn.commit();
	conn.setAutoCommit(true);
	
} catch(SQLException e) {
	e.printStackTrace();
       String message = "Failure: Your entry failed " + e.getMessage();
   	%>
	<h1><%=message %></h1>
	<%
} 
	
%>

<!-- HTML Body Start -->
<body>

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
			Course Number: (ex. CSE132) 
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


</body>
<!-- HTML Body End -->

<%

if (conn != null)
	conn.close();
%>

</html>