/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Dao;
import ConexionDB.CifradoAES;
import ConexionDB.Conexion;
import Modelos.Cliente;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author vicen
 */
public class ClienteDAO {

    public List<Cliente> listar() {
        List<Cliente> lista = new ArrayList<>();
        String sql = "SELECT * FROM cliente ORDER BY cliente_id ASC";

        try (Connection con = Conexion.getConexion(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Cliente c = new Cliente();
                c.setClienteId(rs.getInt("cliente_id"));
                c.setNombre(CifradoAES.descifrar(rs.getString("nombre")));
                c.setApPaterno(CifradoAES.descifrar(rs.getString("ap_paterno")));
                c.setApMaterno(CifradoAES.descifrar(rs.getString("ap_materno")));
                c.setTelefono(CifradoAES.descifrar(rs.getString("telefono")));
                c.setCorreo(CifradoAES.descifrar(rs.getString("correo")));
                c.setCreadoEn(rs.getTimestamp("creado_en"));
                lista.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public boolean insertar(Cliente c) {
        String sql = "INSERT INTO cliente (cliente_id,nombre, ap_paterno, ap_materno, telefono, correo, creado_en) VALUES (?,?, ?, ?, ?, ?, NOW())";
        try (Connection con = Conexion.getConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, c.getClienteId());
            ps.setString(2, CifradoAES.cifrar(c.getNombre()));
            ps.setString(3, CifradoAES.cifrar(c.getApPaterno()));
            ps.setString(4, CifradoAES.cifrar(c.getApMaterno()));
            ps.setString(5, CifradoAES.cifrar(c.getTelefono()));
            ps.setString(6, CifradoAES.cifrar(c.getCorreo()));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean actualizar(Cliente c) {
        String sql = "UPDATE cliente SET nombre=?, ap_paterno=?, ap_materno=?, telefono=?, correo=? WHERE cliente_id=?";
        try (Connection con = Conexion.getConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, CifradoAES.cifrar(c.getNombre()));
            ps.setString(2, CifradoAES.cifrar(c.getApPaterno()));
            ps.setString(3, CifradoAES.cifrar(c.getApMaterno()));
            ps.setString(4, CifradoAES.cifrar(c.getTelefono()));
            ps.setString(5, CifradoAES.cifrar(c.getCorreo()));
            ps.setInt(6, c.getClienteId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    
    //DOPATCH
    public boolean actualizarParcial(int id, String telefono, String correo) {
        String sql = "UPDATE cliente SET "
                + "telefono = COALESCE(?, telefono), "
                + "correo = COALESCE(?, correo) "
                + "WHERE cliente_id = ?";

        try (Connection con = Conexion.getConexion(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, CifradoAES.cifrar(telefono));
            ps.setString(2, CifradoAES.cifrar(correo));
            ps.setInt(3, id);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean eliminar(int id) {
        String sql = "DELETE FROM cliente WHERE cliente_id=?";
        try (Connection con = Conexion.getConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
