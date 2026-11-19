/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Dao;

import ConexionDB.Conexion;
import Modelos.Ingrediente;
import Modelos.InventarioProducto;
import Modelos.LoteInventario;
import Modelos.PasoReceta;
import Modelos.Receta;
import Modelos.RecetaIngrediente;
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
public class InventarioYRecetaDAO {

    public List<Ingrediente> listarIngredientes() {
        List<Ingrediente> lista = new ArrayList<>();
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM ingrediente ORDER BY ingrediente_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Ingrediente i = new Ingrediente();
                i.setIngredienteId(rs.getInt("ingrediente_id"));
                i.setNombre(rs.getString("nombre"));
                i.setUnidadMedidaId(rs.getInt("unidad_medida_id"));
                i.setCostoPorUnidad(rs.getBigDecimal("costo_por_unidad"));
                lista.add(i);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public boolean insertarIngrediente(Ingrediente i) {
        String sql = "INSERT INTO ingrediente (nombre, unidad_medida_id, costo_por_unidad) VALUES (?, ?, ?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, i.getNombre());
            ps.setInt(2, i.getUnidadMedidaId());
            ps.setBigDecimal(3, i.getCostoPorUnidad());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean registrarLote(LoteInventario l) {
        String sql = "INSERT INTO lote_inventario (ingrediente_id, numero_lote, cantidad, unidad_medida_id, fecha_caducidad, creado_en) VALUES (?, ?, ?, ?, ?, NOW())";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setObject(1, l.getIngredienteId(), Types.INTEGER);
            ps.setString(2, l.getNumeroLote());
            ps.setBigDecimal(3, l.getCantidad());
            ps.setObject(4, l.getUnidadMedidaId(), Types.INTEGER);
            ps.setDate(5, l.getFechaCaducidad());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean actualizarStockProducto(InventarioProducto inv) {
        String sql = "UPDATE inventario_producto SET stock_disponible = ?, stock_minimo = ?, actualizado_en = NOW() WHERE producto_id = ?";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, inv.getStockDisponible());
            ps.setInt(2, inv.getStockMinimo());
            ps.setInt(3, inv.getProductoId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean guardarRecetaCompleta(Receta r) {
        String sqlReceta = "INSERT INTO receta (producto_id, rendimiento, tiempo_estimado_min) VALUES (?, ?, ?) RETURNING receta_id";
        String sqlIng = "INSERT INTO receta_ingrediente (receta_id, ingrediente_id, cantidad) VALUES (?, ?, ?)";
        String sqlPaso = "INSERT INTO paso_receta (receta_id, numero_paso, descripcion) VALUES (?, ?, ?)";

        Connection con = null;
        try {
            con = Conexion.getConexion();
            con.setAutoCommit(false);

            int recetaId = 0;
            try (PreparedStatement ps = con.prepareStatement(sqlReceta)) {
                ps.setObject(1, r.getProductoId(), Types.INTEGER);
                ps.setObject(2, r.getRendimiento(), Types.INTEGER);
                ps.setObject(3, r.getTiempoEstimadoMin(), Types.INTEGER);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) recetaId = rs.getInt(1);
                }
            }

            if (r.getIngredientes() != null) {
                try (PreparedStatement psIng = con.prepareStatement(sqlIng)) {
                    for (RecetaIngrediente ri : r.getIngredientes()) {
                        psIng.setInt(1, recetaId);
                        psIng.setInt(2, ri.getIngredienteId());
                        psIng.setBigDecimal(3, ri.getCantidad());
                        psIng.addBatch();
                    }
                    psIng.executeBatch();
                }
            }

            if (r.getPasos() != null) {
                try (PreparedStatement psPaso = con.prepareStatement(sqlPaso)) {
                    for (PasoReceta pr : r.getPasos()) {
                        psPaso.setInt(1, recetaId);
                        psPaso.setObject(2, pr.getNumeroPaso(), Types.INTEGER);
                        psPaso.setString(3, pr.getDescripcion());
                        psPaso.addBatch();
                    }
                    psPaso.executeBatch();
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
}