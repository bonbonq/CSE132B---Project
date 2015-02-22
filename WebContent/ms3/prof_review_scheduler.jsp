<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Prof Review Scheduler</title>
<%

Connection conn = null;

String sql1 = null;
PreparedStatement ps1 = null;
ResultSet rs1 = null;

String sql2 = null;
PreparedStatement ps2 = null;
ResultSet rs2 = null;

String action = request.getParameter("action");

try
{
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection("jdbc:postgresql://localhost/CSE132B");
	conn.setAutoCommit(false);
	
	String smonth = request.getParameter("smonth");
	String sday = request.getParameter("sday");
	String emonth = request.getParameter("emonth");
	String eday = request.getParameter("eday");
	boolean numerror = false;
	
	String idsection_string = request.getParameter("idsection");
	int idsection;
	HashSet<String> [] days = null;
	String [] dayHashValues = {"M", "Tu", "W", "Th", "F"};
	String [] months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
	String [] hours = {"00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"};
	int [] month_days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
	
	if (action != null && action.equals("list"))
	{
		if (Integer.parseInt(smonth) > Integer.parseInt(emonth))
		{
			action = null;
			numerror = true;
		}
		else if (Integer.parseInt(smonth) == Integer.parseInt(emonth))
		{
			if (Integer.parseInt(sday) > Integer.parseInt(eday))
			{
				action = null;
				numerror = true;
			}
		}
	}
	
	if (action != null && action.equals("list"))
	{
			idsection = Integer.parseInt(idsection_string);
			days = new HashSet[5];
			int index;
			String start_string;
			String end_string;
			
			String start_hour;
			String end_hour; 
			
			for (int i = 0; i < 5; i++)
				days[i] = new HashSet<String>();
			
			String dayString;
			java.sql.Time startTime;
			java.sql.Time endTime;
				
			sql1 = "SELECT day_of_week, start_time, end_time" +
				   " FROM section_weekly, weekly " +
			       " WHERE section_weekly.idsection = ?";
			ps1 = conn.prepareStatement(sql1);
			ps1.setInt(1, idsection);
			rs1 = ps1.executeQuery();
			if (!(rs1.isBeforeFirst()))
			{
				throw new SQLException("Invalid section number given");	
			}
	
			while(rs1.next())
			{
				dayString = rs1.getString("day_of_week");
				for (int i = 0; i < 5; i++)
				{
					index = dayString.indexOf(dayHashValues[i]);
					if (index != -1)
					{
						startTime = rs1.getTime("start_time");
						endTime = rs1.getTime("end_time");
					
						start_string = startTime.toString();
						end_string = endTime.toString();
					
						start_hour = start_string.substring(0, 2);
						end_hour = start_string.substring(0, 2);
						
						days[i].add(dayHashValues[i]);
					}
				}
			}
			
			sql2 = "SELECT day_of_week, start_time, end_time" +
					   " FROM section_weekly, weekly " +
				       " WHERE section_weekly.idsection = ?";
			ps2 = conn.prepareStatement(sql1);
			ps2.setInt(1, idsection);
			rs2 = ps1.executeQuery();
			if (!(rs2.isBeforeFirst()))
			{
				throw new SQLException("Invalid section number given");	
			}
			
			while(rs2.next())
			{
				dayString = rs2.getString("day_of_week");
				for (int i = 0; i < 5; i++)
				{
					index = dayString.indexOf(dayHashValues[i]);
					if (index != -1)
					{
						startTime = rs2.getTime("start_time");
						endTime = rs2.getTime("end_time");
					
						start_string = startTime.toString();
						end_string = endTime.toString();
						
						start_hour = start_string.substring(0, 2);
						end_hour = start_string.substring(0, 2);
							
						days[i].add(dayHashValues[i]);
					}
				}
			}			
	}
	else
	{
		sql1 = "SELECT class.title, faculty_class_section.idclass, faculty_class_section.faculty_name, faculty_class_section.idsection FROM class, faculty_class_section"; 
		ps1 = conn.prepareStatement(sql1);
		rs1 = ps1.executeQuery();	
	}


%>
</head>

<body>
<h2>Review Session Scheduler</h2>
<% 
if (action != null && action.equals("list"))
{
	idsection = Integer.parseInt(idsection_string);
	int smonth_int = Integer.parseInt(smonth);
	int emonth_int = Integer.parseInt(emonth);
	int sday_int = Integer.parseInt(sday);
	int eday_int = Integer.parseInt(eday);
	%>
	<ul>
	<%
	int h = sday_int;
	int g = smonth_int;
	boolean done = false;
	while (done == false)
	{
		for (int i = 0; i < 5 && done == false; i++, h++)
		{
			if (h > month_days[g - 1])
			{
				h = 1;
				g = (g + 1) % 12;
			}
			
			if (g == emonth_int && h >= eday_int)
				done = true;
			
			for (int j = 8; j < 20; j++)
			{
				if (days != null  && days[i] != null && !(days[i].contains((hours[j]))))
				{
				%>
					<li><%=months[g]%> <%=h%> <%=hours[j]%>:00 - <%=hours[((j + 1) % 24)]%>:00</li>
				<%
				}
			}	
		}
		h += 2;
		if (h > month_days[g - 1])
		{
			h = h % (month_days[g - 1]);
			g = (g + 1) % 12;
		}
	}
	%>
	</ul>
	<%
}

else
{
	if (rs1.isBeforeFirst())
	{
		if (numerror == true)
		{
		%>
		<h3>Error: Please make sure end date is later than start date</h3>
		<%
		}
		%>
		<h3>Select Section:</h3>
		<form action="prof_review_scheduler.jsp" method="POST">
		<select name="idsection">
		<%
		while (rs1.next())
		{
		%>
			<option value="<%=rs1.getInt("idsection")%>">CID: <%=rs1.getInt("idclass")%> - SID: <%=rs1.getInt("idsection")%> - <%=rs1.getString("title") %></option>
			<%
			}
			%>
			Start Date:
			</select>
			<select name="smonth">
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
					<select name="sday">
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
					
			End Date:
			<select name="emonth">
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
					<select name="eday">
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
			<input type="hidden" name="action" value="list">
			<input type="submit">
		</form>
		<%
		}
		else
		{
		%>
			<h3>Error: Cannot Process Request</h3>
			<h4>No sections found in database</h4>
			<a href="../section.jsp"><button>Add Sections</button></a>
		<%
		}
	}
}

catch (SQLException e)
{
	conn.rollback();
	e.printStackTrace();
}

finally
{
	if (conn != null)
		conn.close();
	if (ps1 != null)
		ps1.close();
	if (rs1 != null)
		rs1.close();
}
%>
</body>
</html>