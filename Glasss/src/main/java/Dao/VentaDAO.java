/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Dao;

import ConexionDB.Conexion;
import Modelos.DetalleVenta;
import Modelos.Venta;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author vicen
 */
public class VentaDAO {

    public boolean registrarVentaCompleta(Venta venta) {
        String sqlVenta = "INSERT INTO venta (empleado_id, cliente_id, metodo_pago_id, estado_venta_id, pedido_id, fecha_venta, fecha_entrega_programada, total) VALUES (?, ?, ?, ?, ?, NOW(), ?, ?) RETURNING venta_id";
        String sqlDetalle = "INSERT INTO detalle_venta (venta_id, producto_id, cantidad, precio_unitario, subtotal) VALUES (?, ?, ?, ?, ?)";

        Connection con = null;
        try {
            con = Conexion.getConexion();
            con.setAutoCommit(false);

            int ventaIdGenerado = 0;
            try (PreparedStatement psVenta = con.prepareStatement(sqlVenta)) {
                psVenta.setObject(1, venta.getEmpleadoId(), Types.INTEGER);
                psVenta.setObject(2, venta.getClienteId(), Types.INTEGER);
                psVenta.setObject(3, venta.getMetodoPagoId(), Types.INTEGER);
                psVenta.setObject(4, venta.getEstadoVentaId(), Types.INTEGER);
                psVenta.setObject(5, venta.getPedidoId(), Types.INTEGER);
                psVenta.setTimestamp(6, venta.getFechaEntregaProgramada());
                psVenta.setBigDecimal(7, venta.getTotal());

                try (ResultSet rs = psVenta.executeQuery()) {
                    if (rs.next()) ventaIdGenerado = rs.getInt(1);
                }
            }

            if (venta.getDetalles() != null && ventaIdGenerado > 0) {
                try (PreparedStatement psDet = con.prepareStatement(sqlDetalle)) {
                    for (DetalleVenta det : venta.getDetalles()) {
                        psDet.setInt(1, ventaIdGenerado);
                        psDet.setObject(2, det.getProductoId(), Types.INTEGER);
                        psDet.setInt(3, det.getCantidad());
                        psDet.setBigDecimal(4, det.getPrecioUnitario());
                        psDet.setBigDecimal(5, det.getSubtotal());
                        psDet.addBatch();
                    }
                    psDet.executeBatch();
                }
            }

            con.commit();
            return true;
        } catch (SQLException e) {
            if (con != null) try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) try { con.setAutoCommit(true); con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    public List<Venta> listarVentas() {
        List<Venta> lista = new ArrayList<>();
        String sql = "SELECT * FROM venta ORDER BY fecha_venta DESC";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Venta v = new Venta();
                v.setVentaId(rs.getInt("venta_id"));
                v.setEmpleadoId((Integer) rs.getObject("empleado_id"));
                v.setClienteId((Integer) rs.getObject("cliente_id"));
                v.setMetodoPagoId((Integer) rs.getObject("metodo_pago_id"));
                v.setEstadoVentaId((Integer) rs.getObject("estado_venta_id"));
                v.setPedidoId((Integer) rs.getObject("pedido_id"));
                v.setFechaVenta(rs.getTimestamp("fecha_venta"));
                v.setFechaEntregaProgramada(rs.getTimestamp("fecha_entrega_programada"));
                v.setTotal(rs.getBigDecimal("total"));
                lista.add(v);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }
}
