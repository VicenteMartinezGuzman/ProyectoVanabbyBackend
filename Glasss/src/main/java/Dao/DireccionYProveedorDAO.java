/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Dao;

import ConexionDB.Conexion;
import Modelos.DireccionCliente;
import Modelos.DireccionEmpleado;
import Modelos.DireccionProveedor;
import Modelos.Proveedor;
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
public class DireccionYProveedorDAO {

    public List<Proveedor> listarProveedores() {
        List<Proveedor> lista = new ArrayList<>();
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM proveedor ORDER BY proveedor_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Proveedor p = new Proveedor();
                p.setProveedorId(rs.getInt("proveedor_id"));
                p.setNombre(rs.getString("nombre"));
                p.setContactoNombre(rs.getString("contacto_nombre"));
                p.setContactoApPaterno(rs.getString("contacto_ap_paterno"));
                p.setContactoApMaterno(rs.getString("contacto_ap_materno"));
                p.setTelefono(rs.getString("telefono"));
                p.setCorreo(rs.getString("correo"));
                p.setNotas(rs.getString("notas"));
                lista.add(p);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public boolean insertarProveedor(Proveedor p) {
        String sql = "INSERT INTO proveedor (nombre, contacto_nombre, contacto_ap_paterno, contacto_ap_materno, telefono, correo, notas) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getContactoNombre());
            ps.setString(3, p.getContactoApPaterno());
            ps.setString(4, p.getContactoApMaterno());
            ps.setString(5, p.getTelefono());
            ps.setString(6, p.getCorreo());
            ps.setString(7, p.getNotas());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public List<DireccionCliente> listarDireccionesCliente(int clienteId) {
        List<DireccionCliente> lista = new ArrayList<>();
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT * FROM direccion_cliente WHERE cliente_id = ?")) {
            ps.setInt(1, clienteId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DireccionCliente d = new DireccionCliente();
                    d.setDireccionId(rs.getInt("direccion_id"));
                    d.setClienteId(rs.getInt("cliente_id"));
                    d.setAlias(rs.getString("alias"));
                    d.setCalle(rs.getString("calle"));
                    d.setNumero(rs.getString("numero"));
                    d.setColonia(rs.getString("colonia"));
                    d.setCiudad(rs.getString("ciudad"));
                    d.setEstadoGeo(rs.getString("estado_geo"));
                    d.setCp(rs.getString("cp"));
                    d.setEsPrincipal((Short) rs.getObject("es_principal"));
                    lista.add(d);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return lista;
    }

    public boolean insertarDireccionCliente(DireccionCliente d) {
        String sql = "INSERT INTO direccion_cliente (cliente_id, alias, calle, numero, colonia, ciudad, estado_geo, cp, es_principal) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, d.getClienteId());
            ps.setString(2, d.getAlias());
            ps.setString(3, d.getCalle());
            ps.setString(4, d.getNumero());
            ps.setString(5, d.getColonia());
            ps.setString(6, d.getCiudad());
            ps.setString(7, d.getEstadoGeo());
            ps.setString(8, d.getCp());
            ps.setObject(9, d.getEsPrincipal(), Types.SMALLINT);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean insertarDireccionEmpleado(DireccionEmpleado d) {
        String sql = "INSERT INTO direccion_empleado (empleado_id, alias, calle, numero, colonia, ciudad, estado_geo, cp, es_principal) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, d.getEmpleadoId());
            ps.setString(2, d.getAlias());
            ps.setString(3, d.getCalle());
            ps.setString(4, d.getNumero());
            ps.setString(5, d.getColonia());
            ps.setString(6, d.getCiudad());
            ps.setString(7, d.getEstadoGeo());
            ps.setString(8, d.getCp());
            ps.setObject(9, d.getEsPrincipal(), Types.SMALLINT);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean insertarDireccionProveedor(DireccionProveedor d) {
        String sql = "INSERT INTO direccion_proveedor (proveedor_id, alias, calle, numero, colonia, ciudad, estado_geo, cp, es_principal) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, d.getProveedorId());
            ps.setString(2, d.getAlias());
            ps.setString(3, d.getCalle());
            ps.setString(4, d.getNumero());
            ps.setString(5, d.getColonia());
            ps.setString(6, d.getCiudad());
            ps.setString(7, d.getEstadoGeo());
            ps.setString(8, d.getCp());
            ps.setObject(9, d.getEsPrincipal(), Types.SMALLINT);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
}