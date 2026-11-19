/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Dao;
import ConexionDB.Conexion;
import Modelos.Producto;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author vicen
 */
public class ProductoDAO {

    public List<Producto> listar() {
        List<Producto> lista = new ArrayList<>();
        String sql = "SELECT * FROM producto ORDER BY producto_id ASC";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Producto p = new Producto();
                p.setProductoId(rs.getInt("producto_id"));
                p.setSku(rs.getString("sku"));
                p.setNombre(rs.getString("nombre"));
                p.setDescripcion(rs.getString("descripcion"));
                p.setImagen(rs.getString("imagen"));
                p.setCategoriaId((Integer) rs.getObject("categoria_id"));
                p.setPrecio(rs.getBigDecimal("precio"));
                p.setTiempoPreparacionMin((Integer) rs.getObject("tiempo_preparacion_min"));
                p.setCreadoEn(rs.getTimestamp("creado_en"));
                lista.add(p);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public boolean insertar(Producto p) {
        String sql = "INSERT INTO producto (sku, nombre, descripcion, imagen, categoria_id, precio, tiempo_preparacion_min, creado_en) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getSku());
            ps.setString(2, p.getNombre());
            ps.setString(3, p.getDescripcion());
            ps.setString(4, p.getImagen());
            ps.setObject(5, p.getCategoriaId(), Types.INTEGER);
            ps.setBigDecimal(6, p.getPrecio());
            ps.setObject(7, p.getTiempoPreparacionMin(), Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean actualizar(Producto p) {
        String sql = "UPDATE producto SET sku=?, nombre=?, descripcion=?, imagen=?, categoria_id=?, precio=?, tiempo_preparacion_min=? WHERE producto_id=?";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getSku());
            ps.setString(2, p.getNombre());
            ps.setString(3, p.getDescripcion());
            ps.setString(4, p.getImagen());
            ps.setObject(5, p.getCategoriaId(), Types.INTEGER);
            ps.setBigDecimal(6, p.getPrecio());
            ps.setObject(7, p.getTiempoPreparacionMin(), Types.INTEGER);
            ps.setInt(8, p.getProductoId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean eliminar(int id) {
        String sql = "DELETE FROM producto WHERE producto_id=?";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
}