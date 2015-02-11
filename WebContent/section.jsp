<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
            <%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>

<%
	String insert = request.getParameter("insert");
	String result = request.getParameter("result");
	String dept = request.getParameter("dept");
	String courseno = request.getParameter("courseno");
	String sectionid = request.getParameter("sectionid");
	String todo = request.getParameter("todo");
	String type = request.getParameter("type");
	
	Connection conn = null;
	PreparedStatement ps1 = null;
	PreparedStatement ps2 = null;
	PreparedStatement ps3 = null;
	PreparedStatement ps4 = null;
	ResultSet rs1 = null;
	ResultSet rs2 = null;
	ResultSet rs3 = null;
	ResultSet rs4 = null;
	
	if (insert != null && insert.equals("true"))
	{
		try
		{
			String building = request.getParameter("building");
			String room = request.getParameter("building");
			String [] days = request.getParameterValues("days");
			int dayslength = days.length;
			String starth = request.getParameter("starth");
			String startm = request.getParameter("startm");
			String startmode = request.getParameter("startmode");
			String endh = request.getParameter("endh");
			String endm = request.getParameter("endm");
			String endmode = request.getParameter("endmode");
			String month = request.getParameter("month");
			String day = request.getParameter("day");
			String year = request.getParameter("year");
			Class.forName("org.postgresql.Driver");
			conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
			conn.setAutoCommit(false);
			
			String daysString = "";
			for (int i = 0; i < dayslength; i++)
				daysString += days[i];
			String startTimeString = "01/02/03 " + starth + ":" + startm + " " + startmode;
			String endTimeString = "01/02/03 " + endh + ":" + endm + " " + endmode;
			
			if (result.equals("lecadd"))
			{
				ps1 = conn.prepareStatement("INSERT INTO weekly (building, room, day_of_week, start_time, end_time, type) " +
						"VALUES ('" + building + "', '" + room + "', '" + daysString + "', '" + startTimeString + "', '" 
						+ endTimeString + "', 'lecture') RETURNING idweekly");
				ps1.execute();
				rs1 = ps1.getResultSet();
				rs1.next();
				int idweekly = rs1.getInt("idweekly");
				ps2 = conn.prepareStatement("INSERT INTO section_weekly (idsection, idweekly) VALUES (" + sectionid + ", " + idweekly + ")");
			}
			else if (result.equals("discadd"))
			{
				ps1 = conn.prepareStatement("INSERT INTO weekly (building, room, day_of_week, start_time, end_time, type) " +
						"VALUES ('" + building + "', '" + room + "', '" + daysString + "', '" + startTimeString + "', '" + endTimeString + "', 'discussion') RETURNING idweekly");
				ps1.execute();
				rs1 = ps1.getResultSet();
				rs1.next();
				int idweekly = rs1.getInt("idweekly");
				ps2 = conn.prepareStatement("INSERT INTO section_weekly (idsection, idweekly) VALUES (" + sectionid + ", " + idweekly + ")");
			}
			else
			{
				String dateString = month + "/" + day + "/" + year; 
				ps1 = conn.prepareStatement("INSERT INTO reviewsession (time, start_time, end_time, building, room)" + 
						" VALUES ('" + dateString + "', '" + startTimeString + "', '" + endTimeString + "', '" + building + "', '" + room + "') RETURNING idreviewsession");
				ps1.execute();
				rs1 = ps1.getResultSet();
				rs1.next();
				int idreview = rs1.getInt("idreviewsession");
				ps2 = conn.prepareStatement("INSERT INTO section_reviewsession (idsection, idreviewsession) VALUES (" + sectionid + ", " + idreview + ")");
			}
			
			ps2.executeUpdate();
			conn.commit();
			
			%><h3><%=type%> successfully added</h3><% 
			todo = "section";
			type = null;
		}
		catch (SQLException e)
		{
			conn.rollback();
			e.printStackTrace();
		}
		finally
		{
			if (ps1 != null)
				ps1.close();
			if (ps2 != null)
				ps2.close();
			if (ps3 != null)
				ps3.close();
			if (ps4 != null)
				ps4.close();
			if (rs1 != null)
				rs1.close();
			if (rs2 != null)
				rs2.close();
			if (rs3 != null)
				rs3.close();
			if (rs4 != null)
				rs4.close();
			
			if (conn != null)
			{
				conn.setAutoCommit(false);
				conn.close();
			}
		}	
	}

	if (todo == null)
	{
		%><h3>Error: Please use Class Entry Form</h3>
		
		<form action="class_entry_form.jsp">
		<input type="submit" value="Go To Class Entry Form">
		</form><%
	}
	
	else if (todo.equals("section") && type == null)
	{
		%>
		<h2>Section Add Form</h2>
		<h3>Department:<%=dept%></h3>
		<h3>Course Number: <%=courseno%></h3>
		<h3>Section ID: <%=sectionid%></h3>
		<form action="section.jsp">
			<input type="hidden" name="type" value="lecture">
			<input type="hidden" name="todo" value="section">
			<input type="hidden" name="dept" value="<%=dept%>">
			<input type="hidden" name="courseno" value="<%=courseno%>">
			<input type="hidden" name="sectionid" value="<%=sectionid%>">
			<input type="submit" value="Add Lecture">
		</form>
		
		<form action="section.jsp">
			<input type="hidden" name="type" value="discussion">
			<input type="hidden" name="todo" value="section">
			<input type="hidden" name="dept" value="<%=dept%>">
			<input type="hidden" name="courseno" value="<%=courseno%>">
			<input type="hidden" name="sectionid" value="<%=sectionid%>">
			<input type="submit" value="Add Discussion">
		</form>
		
		<form action="section.jsp">
			<input type="hidden" name="type" value="review">
			<input type="hidden" name="todo" value="section">
			<input type="hidden" name="dept" value="<%=dept%>">
			<input type="hidden" name="courseno" value="<%=courseno%>">
			<input type="hidden" name="sectionid" value="<%=sectionid%>">
			<input type="submit" value="Add Review Session">
		</form><%
	}
	
	if (type != null)
	{
		%>
		<h2>Section Add Form</h2>
		<h3>Department:<%=dept%></h3>
		<h3>Course Number: <%=courseno%></h3>
		<h3>Section ID: <%=sectionid%></h3>
		<form action="section.jsp" method="POST"><%
		if (type.equals("review"))
		{
		
		%><h3>Adding a Review Session:</h3>
		<input type="hidden" name="result" value="revadd">
		<input type="hidden" name="type" value="Review Session">
		
		<select name="month">
			<option value="01">1</option>
			<option value="02">2</option>
			<option value="03">3</option>
			<option value="04">4</option>
			<option value="05">5</option>
			<option value="06">6</option>
			<option value="07">7</option>
			<option value="08">8</option>
			<option value="09">9</option>
			<option value="10">10</option>
			<option value="11">11</option>
			<option value="12">12</option>
		</select>
		/
		
		<select name="day">
			<option value="01">1</option>
			<option value="02">2</option>
			<option value="03">3</option>
			<option value="04">4</option>
			<option value="05">5</option>
			<option value="06">6</option>
			<option value="07">7</option>
			<option value="08">8</option>
			<option value="09">9</option>
			<option value="10">10</option>
			<option value="11">11</option>
			<option value="12">12</option>
			<option value="13">13</option>
			<option value="14">14</option>
			<option value="15">15</option>
			<option value="16">16</option>
			<option value="17">17</option>
			<option value="18">18</option>
			<option value="19">19</option>
			<option value="20">20</option>
			<option value="21">21</option>
			<option value="22">22</option>
			<option value="23">23</option>
			<option value="24">24</option>
			<option value="25">25</option>
			<option value="26">26</option>
			<option value="27">27</option>
			<option value="28">28</option>
			<option value="29">29</option>
			<option value="30">30</option>
			<option value="31">31</option>
		</select>
		/
		<select name="year">
			<option value="2015">2015</option>
			<option value="2016">2016</option>
			<option value="2017">2017</option>
		</select>
		
		<% 
	}
	else if (type.equals("lecture"))
	{
		%>
		<h3>Adding a Lecture:</h3>
		<input type="hidden" name="result" value="lecadd">
		Days of Week:
		<input type="checkbox" name="days" value="M">M
		<input type="checkbox" name="days" value="Tu">Tu
		<input type="checkbox" name="days" value="W">W
		<input type="checkbox" name="days" value="Th">Th
		<input type="checkbox" name="days" value="F">F
		<input type="checkbox" name="days" value="Sa">Sa
		<input type="checkbox" name="days" value="Su">Su
		<input type="hidden" name="type" value="Lecture">
<%
	}
	else
	{
		%>
		<h3>Adding a Discussion:</h3>
		<input type="hidden" name="result" value="discadd">
		Days of Week:
		<input type="checkbox" name="days" value="M">M
		<input type="checkbox" name="days" value="Tu">Tu
		<input type="checkbox" name="days" value="W">W
		<input type="checkbox" name="days" value="Th">Th
		<input type="checkbox" name="days" value="F">F
		<input type="checkbox" name="days" value="Sa">Sa
		<input type="checkbox" name="days" value="Su">Su
		<input type="hidden" name="type" value="Discussion">
		<%
	}

%>
		Start Time:
		<select name="starth">
			<option value="01">1</option>
			<option value="02">2</option>
			<option value="03">3</option>
			<option value="04">4</option>
			<option value="05">5</option>
			<option value="06">6</option>
			<option value="07">7</option>
			<option value="08">8</option>
			<option value="09">9</option>
			<option value="10">10</option>
			<option value="11">11</option>
			<option value="11">12</option>
		</select>
		:
		<select name="startm">
			<option value="00">00</option>
			<option value="10">10</option>
			<option value="20">20</option>
			<option value="30">30</option>
			<option value="40">40</option>
			<option value="50">50</option>
		</select>
		<select name="startmode">
			<option value="am">AM</option>
			<option value="pm">PM</option>
		</select>
		End Time:
		<select name="endh">
			<option value="01">01</option>
			<option value="02">02</option>
			<option value="03">03</option>
			<option value="04">04</option>
			<option value="05">05</option>
			<option value="06">06</option>
			<option value="07">07</option>
			<option value="08">08</option>
			<option value="09">09</option>
			<option value="10">10</option>
			<option value="11">11</option>
			<option value="12">12</option>
		</select>
		:
		<select name="endm">
			<option value="00">00</option>
			<option value="10">10</option>
			<option value="20">20</option>
			<option value="30">30</option>
			<option value="40">40</option>
			<option value="50">50</option>
		</select>
		<select name="endmode">
			<option value="am">AM</option>
			<option value="pm">PM</option>
		</select>
		
		<label for="building">Location:</label>
		<input type="text" name="building">
		<label for="room">Room:</label>
		<input type="text" name="room">
		<input type="hidden" name="insert" value="true">
		<input type="hidden" name="todo" value="insert">
		<input type="hidden" name="dept" value="<%=dept%>">
		<input type="hidden" name="courseno" value="<%=courseno%>">
		<input type="hidden" name="sectionid" value="<%=sectionid%>">
		<input type="submit">
</form>
<%
	}
%>
</body>
</html>