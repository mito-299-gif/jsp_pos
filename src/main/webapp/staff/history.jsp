<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
// Check authentication
if (session.getAttribute("userId") == null) {
    response.sendRedirect("../login.jsp");
    return;
}

int userId = (Integer) session.getAttribute("userId");
DecimalFormat df = new DecimalFormat("#,##0.00");
SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

// Get filter parameters
String dateFrom = request.getParameter("dateFrom");
String dateTo = request.getParameter("dateTo");
String searchCode = request.getParameter("searchCode");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ประวัติการส่งออก - Export POS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f5f6fa;
        }
        .navbar-custom {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .stat-card {
            border-left: 4px solid;
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-dark navbar-custom mb-4">
        <div class="container-fluid">
            <span class="navbar-brand">
                <i class="bi bi-clock-history"></i> ประวัติการส่งออก
            </span>
            <div class="d-flex align-items-center text-white">
                <i class="bi bi-person-circle me-2"></i>
                <span class="me-3"><%= session.getAttribute("fullName") %></span>
                <a href="pos.jsp" class="btn btn-light btn-sm me-2">
                    <i class="bi bi-shop"></i> POS
                </a>
                <a href="orders.jsp" class="btn btn-light btn-sm me-2">
                    <i class="bi bi-receipt"></i> รายการสั่งซื้อ
                </a>
                <a href="../logout.jsp" class="btn btn-warning btn-sm">
                    <i class="bi bi-box-arrow-right"></i> Logout
                </a>
            </div>
        </div>
    </nav>
    
    <div class="container-fluid px-4">
        <!-- Summary Statistics -->
        <div class="row g-3 mb-4">
            <%
            double totalRevenue = 0;
            int totalExports = 0;
            int totalQuantity = 0;
            
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                    "root", "Admin"
                );
                
                StringBuilder sql = new StringBuilder(
                    "SELECT COUNT(*) as count, SUM(quantity) as qty, SUM(total_price) as revenue " +
                    "FROM exports WHERE user_id = ? "
                );
                
                if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                    sql.append("AND DATE(export_date) BETWEEN ? AND ? ");
                }
                
                ps = conn.prepareStatement(sql.toString());
                ps.setInt(1, userId);
                
                if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                    ps.setString(2, dateFrom);
                    ps.setString(3, dateTo);
                }
                
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    totalExports = rs.getInt("count");
                    totalQuantity = rs.getInt("qty");
                    totalRevenue = rs.getDouble("revenue");
                }
                
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
            %>
            
            <div class="col-md-4">
                <div class="card stat-card border-primary shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="text-muted">ยอดส่งออกทั้งหมด</h6>
                                <h3><%= totalExports %> รายการ</h3>
                            </div>
                            <div class="bg-primary bg-opacity-10 rounded p-3">
                                <i class="bi bi-truck text-primary" style="font-size: 2rem;"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card stat-card border-info shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="text-muted">จำนวนสินค้า</h6>
                                <h3><%= totalQuantity %> ชิ้น</h3>
                            </div>
                            <div class="bg-info bg-opacity-10 rounded p-3">
                                <i class="bi bi-box text-info" style="font-size: 2rem;"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card stat-card border-success shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="text-muted">มูลค่ารวม</h6>
                                <h3 class="text-success">฿<%= df.format(totalRevenue) %></h3>
                            </div>
                            <div class="bg-success bg-opacity-10 rounded p-3">
                                <i class="bi bi-cash-coin text-success" style="font-size: 2rem;"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Filter Form -->
        <div class="card shadow-sm mb-4">
            <div class="card-body">
                <form method="GET" class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label">
                            <i class="bi bi-calendar"></i> วันที่เริ่มต้น
                        </label>
                        <input type="date" class="form-control" name="dateFrom" 
                               value="<%= dateFrom != null ? dateFrom : "" %>">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">
                            <i class="bi bi-calendar"></i> วันที่สิ้นสุด
                        </label>
                        <input type="date" class="form-control" name="dateTo" 
                               value="<%= dateTo != null ? dateTo : "" %>">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">
                            <i class="bi bi-search"></i> ค้นหารหัสส่งออก
                        </label>
                        <input type="text" class="form-control" name="searchCode" 
                               placeholder="EXP..."
                               value="<%= searchCode != null ? searchCode : "" %>">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">&nbsp;</label>
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-search"></i> ค้นหา
                            </button>
                        </div>
                    </div>
                    <div class="col-12">
                        <a href="history.jsp" class="btn btn-secondary btn-sm">
                            <i class="bi bi-x-circle"></i> ล้างค่า
                        </a>
                        <button type="button" class="btn btn-success btn-sm" onclick="window.print()">
                            <i class="bi bi-printer"></i> Print
                        </button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- History Table -->
        <div class="card shadow-sm">
            <div class="card-header bg-white">
                <h5 class="mb-0">
                    <i class="bi bi-list-ul"></i> รายการส่งออกของฉัน
                </h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-light">
                            <tr>
                                <th>รหัสส่งออก</th>
                                <th>วันที่</th>
                                <th>สินค้า</th>
                                <th>จำนวน</th>
                                <th>ราคา/หน่วย</th>
                                <th>ราคารวม</th>
                                <th>หมายเหตุ</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try {
                                conn = DriverManager.getConnection(
                                    "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                    "root", "Admin"
                                );
                                
                                StringBuilder sql = new StringBuilder(
                                    "SELECT e.export_code, e.export_date, p.product_name, p.product_code, " +
                                    "e.quantity, e.unit_price, e.total_price, e.notes " +
                                    "FROM exports e " +
                                    "JOIN products p ON e.product_id = p.id " +
                                    "WHERE e.user_id = ? "
                                );
                                
                                if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                                    sql.append("AND DATE(e.export_date) BETWEEN ? AND ? ");
                                }
                                
                                if (searchCode != null && !searchCode.isEmpty()) {
                                    sql.append("AND e.export_code LIKE ? ");
                                }
                                
                                sql.append("ORDER BY e.export_date DESC");
                                
                                ps = conn.prepareStatement(sql.toString());
                                ps.setInt(1, userId);
                                
                                int paramIndex = 2;
                                if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                                    ps.setString(paramIndex++, dateFrom);
                                    ps.setString(paramIndex++, dateTo);
                                }
                                
                                if (searchCode != null && !searchCode.isEmpty()) {
                                    ps.setString(paramIndex++, "%" + searchCode + "%");
                                }
                                
                                rs = ps.executeQuery();
                                
                                boolean hasData = false;
                                while (rs.next()) {
                                    hasData = true;
                            %>
                            <tr>
                                <td>
                                    <span class="badge bg-primary"><%= rs.getString("export_code") %></span>
                                </td>
                                <td><%= sdf.format(rs.getTimestamp("export_date")) %></td>
                                <td>
                                    <strong><%= rs.getString("product_name") %></strong><br>
                                    <small class="text-muted"><%= rs.getString("product_code") %></small>
                                </td>
                                <td class="text-center">
                                    <span class="badge bg-secondary"><%= rs.getInt("quantity") %></span>
                                </td>
                                <td class="text-end">฿<%= df.format(rs.getDouble("unit_price")) %></td>
                                <td class="text-end text-success fw-bold">
                                    ฿<%= df.format(rs.getDouble("total_price")) %>
                                </td>
                                <td>
                                    <% 
                                    String notes = rs.getString("notes");
                                    if (notes != null && !notes.isEmpty()) { 
                                    %>
                                        <span class="text-muted"><%= notes %></span>
                                    <% } else { %>
                                        <span class="text-muted">-</span>
                                    <% } %>
                                </td>
                            </tr>
                            <%
                                }
                                
                                if (!hasData) {
                            %>
                            <tr>
                                <td colspan="7" class="text-center py-5">
                                    <i class="bi bi-inbox" style="font-size: 3rem; color: #ccc;"></i>
                                    <p class="text-muted mt-3">ไม่พบข้อมูลการส่งออก</p>
                                </td>
                            </tr>
                            <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            } finally {
                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                if (conn != null) try { conn.close(); } catch (SQLException e) {}
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <!-- Top Products Chart -->
        <div class="row mt-4">
            <div class="col-md-6">
                <div class="card shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">
                            <i class="bi bi-bar-chart"></i> สินค้าที่ส่งออกมากที่สุด (Top 5)
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>อันดับ</th>
                                        <th>สินค้า</th>
                                        <th class="text-end">จำนวน</th>
                                        <th class="text-end">มูลค่า</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                    try {
                                        conn = DriverManager.getConnection(
                                            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                            "root", "Admin"
                                        );
                                        
                                        ps = conn.prepareStatement(
                                            "SELECT p.product_name, SUM(e.quantity) as total_qty, " +
                                            "SUM(e.total_price) as total_price " +
                                            "FROM exports e " +
                                            "JOIN products p ON e.product_id = p.id " +
                                            "WHERE e.user_id = ? " +
                                            "GROUP BY p.id, p.product_name " +
                                            "ORDER BY total_qty DESC LIMIT 5"
                                        );
                                        ps.setInt(1, userId);
                                        rs = ps.executeQuery();
                                        
                                        int rank = 1;
                                        boolean hasTopProducts = false;
                                        
                                        while (rs.next()) {
                                            hasTopProducts = true;
                                    %>
                                    <tr>
                                        <td>
                                            <span class="badge bg-primary">#<%= rank++ %></span>
                                        </td>
                                        <td><%= rs.getString("product_name") %></td>
                                        <td class="text-end"><%= rs.getInt("total_qty") %></td>
                                        <td class="text-end text-success">
                                            ฿<%= df.format(rs.getDouble("total_price")) %>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                        
                                        if (!hasTopProducts) {
                                    %>
                                    <tr>
                                        <td colspan="4" class="text-center text-muted">ยังไม่มีข้อมูล</td>
                                    </tr>
                                    <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                        if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                        if (conn != null) try { conn.close(); } catch (SQLException e) {}
                                    }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="card shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">
                            <i class="bi bi-calendar3"></i> สรุปรายเดือน
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>เดือน/ปี</th>
                                        <th class="text-end">รายการ</th>
                                        <th class="text-end">มูลค่า</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                    try {
                                        conn = DriverManager.getConnection(
                                            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                            "root", "Admin"
                                        );
                                        
                                        ps = conn.prepareStatement(
                                            "SELECT DATE_FORMAT(export_date, '%m/%Y') as month_year, " +
                                            "COUNT(*) as count, SUM(total_price) as revenue " +
                                            "FROM exports " +
                                            "WHERE user_id = ? " +
                                            "GROUP BY DATE_FORMAT(export_date, '%Y-%m') " +
                                            "ORDER BY DATE_FORMAT(export_date, '%Y-%m') DESC " +
                                            "LIMIT 6"
                                        );
                                        ps.setInt(1, userId);
                                        rs = ps.executeQuery();
                                        
                                        boolean hasMonthlyData = false;
                                        
                                        while (rs.next()) {
                                            hasMonthlyData = true;
                                    %>
                                    <tr>
                                        <td><%= rs.getString("month_year") %></td>
                                        <td class="text-end"><%= rs.getInt("count") %></td>
                                        <td class="text-end text-success">
                                            ฿<%= df.format(rs.getDouble("revenue")) %>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                        
                                        if (!hasMonthlyData) {
                                    %>
                                    <tr>
                                        <td colspan="3" class="text-center text-muted">ยังไม่มีข้อมูล</td>
                                    </tr>
                                    <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                        if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                        if (conn != null) try { conn.close(); } catch (SQLException e) {}
                                    }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="mb-5"></div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>