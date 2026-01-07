<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
// Check authentication
if (session.getAttribute("userId") == null || !"ADMIN".equals(session.getAttribute("role"))) {
    response.sendRedirect("../login.jsp");
    return;
}

// Handle Export
String exportType = request.getParameter("export");
if (exportType != null) {
    String dateFrom = request.getParameter("dateFrom");
    String dateTo = request.getParameter("dateTo");
    
    if ("excel".equals(exportType)) {
        response.setContentType("application/vnd.ms-excel");
        response.setHeader("Content-Disposition", "attachment; filename=export_report_" +
            new SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date()) + ".xls");
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                "root", "Admin"
            );
            
            String sql = "SELECT e.export_code, e.export_date, p.product_code, p.product_name, " +
                        "e.quantity, e.unit_price, e.total_price, u.full_name, e.notes " +
                        "FROM exports e " +
                        "JOIN products p ON e.product_id = p.id " +
                        "JOIN users u ON e.user_id = u.id ";
            
            if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                sql += "WHERE DATE(e.export_date) BETWEEN ? AND ? ";
            }
            
            sql += "ORDER BY e.export_date DESC";
            
            ps = conn.prepareStatement(sql);
            
            if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                ps.setString(1, dateFrom);
                ps.setString(2, dateTo);
            }
            
            rs = ps.executeQuery();
            
            // Excel Header
            out.println("<html><head><meta charset='UTF-8'></head><body>");
            out.println("<table border='1'>");
            out.println("<tr style='background-color: #4CAF50; color: white;'>");
            out.println("<th>รหัสส่งออก</th>");
            out.println("<th>วันที่</th>");
            out.println("<th>รหัสสินค้า</th>");
            out.println("<th>ชื่อสินค้า</th>");
            out.println("<th>จำนวน</th>");
            out.println("<th>ราคา/หน่วย</th>");
            out.println("<th>ราคารวม</th>");
            out.println("<th>พนักงาน</th>");
            out.println("<th>หมายเหตุ</th>");
            out.println("</tr>");
            
            DecimalFormat df = new DecimalFormat("#,##0.00");
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            double grandTotal = 0;
            
            while (rs.next()) {
                double total = rs.getDouble("total_price");
                grandTotal += total;
                
                out.println("<tr>");
                out.println("<td>" + rs.getString("export_code") + "</td>");
                out.println("<td>" + sdf.format(rs.getTimestamp("export_date")) + "</td>");
                out.println("<td>" + rs.getString("product_code") + "</td>");
                out.println("<td>" + rs.getString("product_name") + "</td>");
                out.println("<td>" + rs.getInt("quantity") + "</td>");
                out.println("<td>" + df.format(rs.getDouble("unit_price")) + "</td>");
                out.println("<td>" + df.format(total) + "</td>");
                out.println("<td>" + rs.getString("full_name") + "</td>");
                out.println("<td>" + (rs.getString("notes") != null ? rs.getString("notes") : "") + "</td>");
                out.println("</tr>");
            }
            
            out.println("<tr style='background-color: #f0f0f0; font-weight: bold;'>");
            out.println("<td colspan='6'>รวมทั้งหมด</td>");
            out.println("<td>" + df.format(grandTotal) + "</td>");
            out.println("<td colspan='2'></td>");
            out.println("</tr>");
            
            out.println("</table>");
            out.println("</body></html>");
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
        
        return;
    }
}

DecimalFormat df = new DecimalFormat("#,##0.00");
SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

// Get filter parameters
String dateFrom = request.getParameter("dateFrom");
String dateTo = request.getParameter("dateTo");
String productFilter = request.getParameter("productFilter");
String userFilter = request.getParameter("userFilter");
%>
<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>รายงาน - Export POS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .sidebar {
            min-height: 100vh;
            background: linear-gradient(180deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .sidebar a {
            color: rgba(255,255,255,0.8);
            text-decoration: none;
            padding: 12px 20px;
            display: block;
            transition: all 0.3s;
        }
        .sidebar a:hover, .sidebar a.active {
            background: rgba(255,255,255,0.2);
            color: white;
        }
        .stat-card {
            border-left: 4px solid;
        }
        @media print {
            .no-print { display: none; }
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 sidebar p-0 no-print">
                <div class="p-4 text-center border-bottom border-white border-opacity-25">
                    <i class="bi bi-box-seam" style="font-size: 3rem;"></i>
                    <h5 class="mt-2">Export POS</h5>
                    <small><%= session.getAttribute("fullName") %></small>
                </div>
                <nav class="mt-3">
                    <a href="dashboard.jsp">
                        <i class="bi bi-speedometer2"></i> Dashboard
                    </a>
                    <a href="products.jsp">
                        <i class="bi bi-box"></i> จัดการสินค้า
                    </a>
                    <a href="users.jsp">
                        <i class="bi bi-people"></i> จัดการพนักงาน
                    </a>
                    <a href="reports.jsp" class="active">
                        <i class="bi bi-file-earmark-text"></i> รายงาน
                    </a>
                    <hr class="border-white border-opacity-25">
                    <a href="../logout.jsp" class="text-warning">
                        <i class="bi bi-box-arrow-right"></i> Logout
                    </a>
                </nav>
            </div>
            
            <!-- Main Content -->
            <div class="col-md-10 p-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="bi bi-file-earmark-text"></i> รายงานการส่งออก</h2>
                    <div class="no-print">
                        <button class="btn btn-success" onclick="exportExcel()">
                            <i class="bi bi-file-earmark-excel"></i> Export Excel
                        </button>
                        <button class="btn btn-info" onclick="window.print()">
                            <i class="bi bi-printer"></i> Print
                        </button>
                    </div>
                </div>
                
                <!-- Filter Form -->
                <div class="card shadow-sm mb-4 no-print">
                    <div class="card-body">
                        <form method="GET" class="row g-3">
                            <div class="col-md-3">
                                <label class="form-label">วันที่เริ่มต้น</label>
                                <input type="date" class="form-control" name="dateFrom" 
                                       value="<%= dateFrom != null ? dateFrom : "" %>">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">วันที่สิ้นสุด</label>
                                <input type="date" class="form-control" name="dateTo" 
                                       value="<%= dateTo != null ? dateTo : "" %>">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">สินค้า</label>
                                <select class="form-select" name="productFilter">
                                    <option value="">ทั้งหมด</option>
                                    <%
                                    Connection conn = null;
                                    PreparedStatement ps = null;
                                    ResultSet rs = null;
                                    
                                    try {
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        conn = DriverManager.getConnection(
                                            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                            "root", "Admin"
                                        );
                                        
                                        ps = conn.prepareStatement("SELECT id, product_name FROM products WHERE status='ACTIVE' ORDER BY product_name");
                                        rs = ps.executeQuery();
                                        
                                        while (rs.next()) {
                                            String selected = String.valueOf(rs.getInt("id")).equals(productFilter) ? "selected" : "";
                                    %>
                                    <option value="<%= rs.getInt("id") %>" <%= selected %>><%= rs.getString("product_name") %></option>
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
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">พนักงาน</label>
                                <select class="form-select" name="userFilter">
                                    <option value="">ทั้งหมด</option>
                                    <%
                                    try {
                                        conn = DriverManager.getConnection(
                                            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                                            "root", "Admin"
                                        );
                                        
                                        ps = conn.prepareStatement("SELECT id, full_name FROM users WHERE status='ACTIVE' ORDER BY full_name");
                                        rs = ps.executeQuery();
                                        
                                        while (rs.next()) {
                                            String selected = String.valueOf(rs.getInt("id")).equals(userFilter) ? "selected" : "";
                                    %>
                                    <option value="<%= rs.getInt("id") %>" <%= selected %>><%= rs.getString("full_name") %></option>
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
                                </select>
                            </div>
                            <div class="col-12">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-search"></i> ค้นหา
                                </button>
                                <a href="reports.jsp" class="btn btn-secondary">
                                    <i class="bi bi-x-circle"></i> ล้างค่า
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
                
                <!-- Summary Statistics -->
                <div class="row g-3 mb-4">
                    <%
                    double totalRevenue = 0;
                    int totalExports = 0;
                    int totalQuantity = 0;
                    
                    try {
                        conn = DriverManager.getConnection(
                            "jdbc:mysql://localhost:3306/export_pos_db?useSSL=false&serverTimezone=UTC",
                            "root", "Admin"
                        );
                        
                        StringBuilder sql = new StringBuilder(
                            "SELECT COUNT(*) as count, SUM(quantity) as qty, SUM(total_price) as revenue " +
                            "FROM exports e WHERE 1=1 "
                        );
                        
                        if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                            sql.append("AND DATE(e.export_date) BETWEEN ? AND ? ");
                        }
                        if (productFilter != null && !productFilter.isEmpty()) {
                            sql.append("AND e.product_id = ? ");
                        }
                        if (userFilter != null && !userFilter.isEmpty()) {
                            sql.append("AND e.user_id = ? ");
                        }
                        
                        ps = conn.prepareStatement(sql.toString());
                        
                        int paramIndex = 1;
                        if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                            ps.setString(paramIndex++, dateFrom);
                            ps.setString(paramIndex++, dateTo);
                        }
                        if (productFilter != null && !productFilter.isEmpty()) {
                            ps.setInt(paramIndex++, Integer.parseInt(productFilter));
                        }
                        if (userFilter != null && !userFilter.isEmpty()) {
                            ps.setInt(paramIndex++, Integer.parseInt(userFilter));
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
                        <div class="card stat-card border-primary">
                            <div class="card-body">
                                <h6 class="text-muted">ยอดส่งออก</h6>
                                <h3><%= totalExports %> รายการ</h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card stat-card border-info">
                            <div class="card-body">
                                <h6 class="text-muted">จำนวนสินค้า</h6>
                                <h3><%= totalQuantity %> ชิ้น</h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card stat-card border-success">
                            <div class="card-body">
                                <h6 class="text-muted">รายได้รวม</h6>
                                <h3 class="text-success">฿<%= df.format(totalRevenue) %></h3>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Report Table -->
                <div class="card shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">รายละเอียดการส่งออก</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover table-bordered">
                                <thead class="table-light">
                                    <tr>
                                        <th>รหัสส่งออก</th>
                                        <th>วันที่</th>
                                        <th>สินค้า</th>
                                        <th>จำนวน</th>
                                        <th>ราคา/หน่วย</th>
                                        <th>ราคารวม</th>
                                        <th>พนักงาน</th>
                                        <th class="no-print">หมายเหตุ</th>
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
                                            "SELECT e.export_code, e.export_date, p.product_name, e.quantity, " +
                                            "e.unit_price, e.total_price, u.full_name, e.notes " +
                                            "FROM exports e " +
                                            "JOIN products p ON e.product_id = p.id " +
                                            "JOIN users u ON e.user_id = u.id WHERE 1=1 "
                                        );
                                        
                                        if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                                            sql.append("AND DATE(e.export_date) BETWEEN ? AND ? ");
                                        }
                                        if (productFilter != null && !productFilter.isEmpty()) {
                                            sql.append("AND e.product_id = ? ");
                                        }
                                        if (userFilter != null && !userFilter.isEmpty()) {
                                            sql.append("AND e.user_id = ? ");
                                        }
                                        
                                        sql.append("ORDER BY e.export_date DESC");
                                        
                                        ps = conn.prepareStatement(sql.toString());
                                        
                                        int paramIndex = 1;
                                        if (dateFrom != null && dateTo != null && !dateFrom.isEmpty() && !dateTo.isEmpty()) {
                                            ps.setString(paramIndex++, dateFrom);
                                            ps.setString(paramIndex++, dateTo);
                                        }
                                        if (productFilter != null && !productFilter.isEmpty()) {
                                            ps.setInt(paramIndex++, Integer.parseInt(productFilter));
                                        }
                                        if (userFilter != null && !userFilter.isEmpty()) {
                                            ps.setInt(paramIndex++, Integer.parseInt(userFilter));
                                        }
                                        
                                        rs = ps.executeQuery();
                                        
                                        if (!rs.isBeforeFirst()) {
                                    %>
                                    <tr>
                                        <td colspan="8" class="text-center text-muted">ไม่พบข้อมูล</td>
                                    </tr>
                                    <%
                                        } else {
                                            while (rs.next()) {
                                    %>
                                    <tr>
                                        <td><%= rs.getString("export_code") %></td>
                                        <td><%= sdf.format(rs.getTimestamp("export_date")) %></td>
                                        <td><%= rs.getString("product_name") %></td>
                                        <td class="text-center"><%= rs.getInt("quantity") %></td>
                                        <td class="text-end">฿<%= df.format(rs.getDouble("unit_price")) %></td>
                                        <td class="text-end text-success fw-bold">฿<%= df.format(rs.getDouble("total_price")) %></td>
                                        <td><%= rs.getString("full_name") %></td>
                                        <td class="no-print"><%= rs.getString("notes") != null ? rs.getString("notes") : "-" %></td>
                                    </tr>
                                    <%
                                            }
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
                                <tfoot class="table-light">
                                    <tr class="fw-bold">
                                        <td colspan="3" class="text-end">รวมทั้งหมด:</td>
                                        <td class="text-center"><%= totalQuantity %></td>
                                        <td></td>
                                        <td class="text-end text-success">฿<%= df.format(totalRevenue) %></td>
                                        <td colspan="2"></td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function exportExcel() {
            const params = new URLSearchParams(window.location.search);
            params.set('export', 'excel');
            window.location.href = 'reports.jsp?' + params.toString();
        }
    </script>
</body>
</html>