/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Dao;

import ConexionDB.Conexion;
import Modelos.Agenda;
import Modelos.Anticipo;
import Modelos.Compra;
import Modelos.DetalleCompra;
import Modelos.Envio;
import Modelos.PagoVenta;
import Modelos.Pedido;
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
public class OperacionesDAO {

    public boolean registrarCompra(Compra c) {
        String sqlCompra = "INSERT INTO compra (proveedor_id, creado_en, fecha_esperada, estado_compra_id) VALUES (?, NOW(), ?, ?) RETURNING compra_id";
        String sqlDet = "INSERT INTO detalle_compra (compra_id, ingrediente_id, cantidad, precio_unitario, subtotal) VALUES (?, ?, ?, ?, ?)";

        Connection con = null;
        try {
            con = Conexion.getConexion();
            con.setAutoCommit(false);

            int compraId = 0;
            try (PreparedStatement ps = con.prepareStatement(sqlCompra)) {
                ps.setObject(1, c.getProveedorId(), Types.INTEGER);
                ps.setDate(2, c.getFechaEsperada());
                ps.setObject(3, c.getEstadoCompraId(), Types.INTEGER);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) compraId = rs.getInt(1);
                }
            }

            if (c.getDetalles() != null) {
                try (PreparedStatement psDet = con.prepareStatement(sqlDet)) {
                    for (DetalleCompra dc : c.getDetalles()) {
                        psDet.setInt(1, compraId);
                        psDet.setObject(2, dc.getIngredienteId(), Types.INTEGER);
                        psDet.setBigDecimal(3, dc.getCantidad());
                        psDet.setBigDecimal(4, dc.getPrecioUnitario());
                        psDet.setBigDecimal(5, dc.getSubtotal());
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

    public boolean insertarPedido(Pedido p) {
        String sql = "INSERT INTO pedido (cliente_id, empleado_id, estado_pedido_id, prioridad_id, fecha_pedido, fecha_entrega_programada) VALUES (?, ?, ?, ?, NOW(), ?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, p.getClienteId());
            ps.setInt(2, p.getEmpleadoId());
            ps.setInt(3, p.getEstadoPedidoId());
            ps.setInt(4, p.getPrioridadId());
            ps.setTimestamp(5, p.getFechaEntregaProgramada());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean insertarEnvio(Envio env) {
        String sql = "INSERT INTO envio (pedido_id, direccion_id, empleado_id, costo_envio, fecha_salida, notas) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, env.getPedidoId());
            ps.setInt(2, env.getDireccionId());
            ps.setObject(3, env.getEmpleadoId(), Types.INTEGER);
            ps.setBigDecimal(4, env.getCostoEnvio());
            ps.setTimestamp(5, env.getFechaSalida());
            ps.setString(6, env.getNotas());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean registrarPagoVenta(PagoVenta pv) {
        String sql = "INSERT INTO pago_venta (venta_id, metodo_pago_id, monto, pagado_en, registrado_por) VALUES (?, ?, ?, NOW(), ?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setObject(1, pv.getVentaId(), Types.INTEGER);
            ps.setObject(2, pv.getMetodoPagoId(), Types.INTEGER);
            ps.setBigDecimal(3, pv.getMonto());
            ps.setObject(4, pv.getRegistradoPor(), Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean registrarAnticipo(Anticipo a) {
        String sql = "INSERT INTO anticipo (venta_id, cliente_id, monto_anticipo, monto_restante, fecha_registro, fecha_limite, estado_anticipo_id, metodo_pago_id) VALUES (?, ?, ?, ?, NOW(), ?, ?, ?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setObject(1, a.getVentaId(), Types.INTEGER);
            ps.setObject(2, a.getClienteId(), Types.INTEGER);
            ps.setBigDecimal(3, a.getMontoAnticipo());
            ps.setBigDecimal(4, a.getMontoRestante());
            ps.setTimestamp(5, a.getFechaLimite());
            ps.setObject(6, a.getEstadoAnticipoId(), Types.INTEGER);
            ps.setObject(7, a.getMetodoPagoId(), Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean agendarEvento(Agenda ag) {
        String sql = "INSERT INTO agenda (venta_id, fecha_programada, responsable_empleado_id, estado_agenda_id, notas) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setObject(1, ag.getVentaId(), Types.INTEGER);
            ps.setTimestamp(2, ag.getFechaProgramada());
            ps.setObject(3, ag.getResponsableEmpleadoId(), Types.INTEGER);
            ps.setObject(4, ag.getEstadoAgendaId(), Types.INTEGER);
            ps.setString(5, ag.getNotas());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public List<Agenda> listarAgenda() {
        List<Agenda> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM agenda ORDER BY fecha_programada ASC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Agenda ag = new Agenda();
                ag.setAgendaId(rs.getInt("agenda_id"));
                ag.setVentaId((Integer) rs.getObject("venta_id"));
                ag.setFechaProgramada(rs.getTimestamp("fecha_programada"));
                ag.setResponsableEmpleadoId((Integer) rs.getObject("responsable_empleado_id"));
                ag.setEstadoAgendaId((Integer) rs.getObject("estado_agenda_id"));
                ag.setNotas(rs.getString("notas"));
                lista.add(ag);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }
}