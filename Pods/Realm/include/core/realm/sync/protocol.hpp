#ifndef REALM_SYNC_PROTOCOL_HPP
#define REALM_SYNC_PROTOCOL_HPP

#include <cstdint>
#include <system_error>

#include <realm/replication.hpp>


// NOTE: The protocol specification is in `/doc/protocol.md`


namespace realm {
namespace sync {

// Protocol versions:
//
//   1 Initial version, matching io.realm.sync-30, but not including query-based
//     sync, serialized transactions, and state realms (async open).
//
//   2 Restored erase-always-wins OT behavior.
//
//   3 Support for Mixed, TypeLinks, Set, and Dictionary columns.
//
//  XX Changes:
//     - TBD
//
constexpr int get_current_protocol_version() noexcept
{
    return 3;
}

constexpr const char* get_websocket_protocol_prefix() noexcept
{
    return "com.mongodb.realm-sync/";
}


/// Supported protocol envelopes:
///
///                                                             Alternative (*)
///      Name     Envelope          URL scheme   Default port   default port
///     ------------------------------------------------------------------------
///      realm    WebSocket         realm:       7800           80
///      realms   WebSocket + SSL   realms:      7801           443
///      ws       WebSocket         ws:          80
///      wss      WebSocket + SSL   wss:         443
///
///       *) When Client::Config::enable_default_port_hack is true
///
enum class ProtocolEnvelope { realm, realms, ws, wss };

inline bool is_ssl(ProtocolEnvelope protocol) noexcept
{
    switch (protocol) {
        case ProtocolEnvelope::realm:
        case ProtocolEnvelope::ws:
            break;
        case ProtocolEnvelope::realms:
        case ProtocolEnvelope::wss:
            return true;
    }
    return false;
}


// These integer types are selected so that they accomodate the requirements of
// the protocol specification (`/doc/protocol.md`).
//
// clang-format off
using file_ident_type    = std::uint_fast64_t;
using version_type       = Replication::version_type;
using salt_type          = std::int_fast64_t;
using timestamp_type     = std::uint_fast64_t;
using session_ident_type = std::uint_fast64_t;
using request_ident_type = std::uint_fast64_t;
using milliseconds_type  = std::int_fast64_t;
// clang-format on

constexpr file_ident_type get_max_file_ident()
{
    return 0x0'7FFF'FFFF'FFFF'FFFF;
}


struct SaltedFileIdent {
    file_ident_type ident;
    /// History divergence and identity spoofing protection.
    salt_type salt;
};

struct SaltedVersion {
    version_type version;
    /// History divergence protection.
    salt_type salt;
};


/// \brief A client's reference to a position in the server-side history.
///
/// A download cursor refers to a position in the server-side history. If
/// `server_version` is zero, the position is at the beginning of the history,
/// otherwise the position is after the entry whose changeset produced that
/// version. In general, positions are to be understood as places between two
/// adjacent history entries.
///
/// `last_integrated_client_version` is the version produced on the client by
/// the last changeset that was sent to the server and integrated into the
/// server-side Realm state at the time indicated by the history position
/// specified by `server_version`, or zero if no changesets from the client were
/// integrated by the server at that point in time.
struct DownloadCursor {
    version_type server_version;
    version_type last_integrated_client_version;
};

/// Checks that `dc.last_integrated_client_version` is zero if
/// `dc.server_version` is zero.
bool is_consistent(DownloadCursor dc) noexcept;

/// Checks that `a.last_integrated_client_version` and
/// `b.last_integrated_client_version` are equal, if `a.server_version` and
/// `b.server_version` are equal. Otherwise checks that
/// `a.last_integrated_client_version` is less than, or equal to
/// `b.last_integrated_client_version`, if `a.server_version` is less than
/// `b.server_version`. Otherwise checks that `a.last_integrated_client_version`
/// is greater than, or equal to `b.last_integrated_client_version`.
bool are_mutually_consistent(DownloadCursor a, DownloadCursor b) noexcept;


/// \brief The server's reference to a position in the client-side history.
///
/// An upload cursor refers to a position in the client-side history. If
/// `client_version` is zero, the position is at the beginning of the history,
/// otherwise the position is after the entry whose changeset produced that
/// version. In general, positions are to be understood as places between two
/// adjacent history entries.
///
/// `last_integrated_server_version` is the version produced on the server by
/// the last changeset that was sent to the client and integrated into the
/// client-side Realm state at the time indicated by the history position
/// specified by `client_version`, or zero if no changesets from the server were
/// integrated by the client at that point in time.
struct UploadCursor {
    version_type client_version;
    version_type last_integrated_server_version;
};

/// Checks that `uc.last_integrated_server_version` is zero if
/// `uc.client_version` is zero.
bool is_consistent(UploadCursor uc) noexcept;

/// Checks that `a.last_integrated_server_version` and
/// `b.last_integrated_server_version` are equal, if `a.client_version` and
/// `b.client_version` are equal. Otherwise checks that
/// `a.last_integrated_server_version` is less than, or equal to
/// `b.last_integrated_server_version`, if `a.client_version` is less than
/// `b.client_version`. Otherwise checks that `a.last_integrated_server_version`
/// is greater than, or equal to `b.last_integrated_server_version`.
bool are_mutually_consistent(UploadCursor a, UploadCursor b) noexcept;


/// A client's record of the current point of progress of the synchronization
/// process. The client must store this persistently in the local Realm file.
struct SyncProgress {
    /// The last server version that the client has heard about.
    SaltedVersion latest_server_version = {0, 0};

    /// The last server version integrated, or about to be integrated by the
    /// client.
    DownloadCursor download = {0, 0};

    /// The last client version integrated by the server.
    UploadCursor upload = {0, 0};
};


/// \brief Protocol errors discovered by the server, and reported to the client
/// by way of ERROR messages.
///
/// These errors will be reported to the client-side application via the error
/// handlers of the affected sessions.
///
/// ATTENTION: Please remember to update is_session_level_error() when
/// adding/removing error codes.
enum class ProtocolError {
    // clang-format off

    // Connection level and protocol errors
    connection_closed            = 100, // Connection closed (no error)
    other_error                  = 101, // Other connection level error
    unknown_message              = 102, // Unknown type of input message
    bad_syntax                   = 103, // Bad syntax in input message head
    limits_exceeded              = 104, // Limits exceeded in input message
    wrong_protocol_version       = 105, // Wrong protocol version (CLIENT) (obsolete)
    bad_session_ident            = 106, // Bad session identifier in input message
    reuse_of_session_ident       = 107, // Overlapping reuse of session identifier (BIND)
    bound_in_other_session       = 108, // Client file bound in other session (IDENT)
    bad_message_order            = 109, // Bad input message order
    bad_decompression            = 110, // Error in decompression (UPLOAD)
    bad_changeset_header_syntax  = 111, // Bad syntax in a changeset header (UPLOAD)
    bad_changeset_size           = 112, // Bad size specified in changeset header (UPLOAD)
    bad_changesets               = 113, // Bad changesets (UPLOAD)

    // Session level errors
    session_closed               = 200, // Session closed (no error)
    other_session_error          = 201, // Other session level error
    token_expired                = 202, // Access token expired
    bad_authentication           = 203, // Bad user authentication (BIND, REFRESH)
    illegal_realm_path           = 204, // Illegal Realm path (BIND)
    no_such_realm                = 205, // No such Realm (BIND)
    permission_denied            = 206, // Permission denied (BIND, REFRESH)
    bad_server_file_ident        = 207, // Bad server file identifier (IDENT) (obsolete!)
    bad_client_file_ident        = 208, // Bad client file identifier (IDENT)
    bad_server_version           = 209, // Bad server version (IDENT, UPLOAD, TRANSACT)
    bad_client_version           = 210, // Bad client version (IDENT, UPLOAD)
    diverging_histories          = 211, // Diverging histories (IDENT)
    bad_changeset                = 212, // Bad changeset (UPLOAD)
    superseded                   = 213, // Superseded by new session for same client-side file (deprecated)
    disabled_session             = 213, // Alias for `superseded` (deprecated)
    partial_sync_disabled        = 214, // Partial sync disabled (BIND)
    unsupported_session_feature  = 215, // Unsupported session-level feature
    bad_origin_file_ident        = 216, // Bad origin file identifier (UPLOAD)
    bad_client_file              = 217, // Synchronization no longer possible for client-side file
    server_file_deleted          = 218, // Server file was deleted while session was bound to it
    client_file_blacklisted      = 219, // Client file has been blacklisted (IDENT)
    user_blacklisted             = 220, // User has been blacklisted (BIND)
    transact_before_upload       = 221, // Serialized transaction before upload completion
    client_file_expired          = 222, // Client file has expired
    user_mismatch                = 223, // User mismatch for client file identifier (IDENT)
    too_many_sessions            = 224, // Too many sessions in connection (BIND)
    invalid_schema_change        = 225, // Invalid schema change (UPLOAD)

    // clang-format on
};

constexpr bool is_session_level_error(ProtocolError);

/// Returns null if the specified protocol error code is not defined by
/// ProtocolError.
const char* get_protocol_error_message(int error_code) noexcept;

const std::error_category& protocol_error_category() noexcept;

std::error_code make_error_code(ProtocolError) noexcept;

} // namespace sync
} // namespace realm

namespace std {

template <>
struct is_error_code_enum<realm::sync::ProtocolError> {
    static const bool value = true;
};

} // namespace std

namespace realm {
namespace sync {


// Implementation

inline bool is_consistent(DownloadCursor dc) noexcept
{
    return (dc.server_version != 0 || dc.last_integrated_client_version == 0);
}

inline bool are_mutually_consistent(DownloadCursor a, DownloadCursor b) noexcept
{
    if (a.server_version < b.server_version)
        return (a.last_integrated_client_version <= b.last_integrated_client_version);
    if (a.server_version > b.server_version)
        return (a.last_integrated_client_version >= b.last_integrated_client_version);
    return (a.last_integrated_client_version == b.last_integrated_client_version);
}

inline bool is_consistent(UploadCursor uc) noexcept
{
    return (uc.client_version != 0 || uc.last_integrated_server_version == 0);
}

inline bool are_mutually_consistent(UploadCursor a, UploadCursor b) noexcept
{
    if (a.client_version < b.client_version)
        return (a.last_integrated_server_version <= b.last_integrated_server_version);
    if (a.client_version > b.client_version)
        return (a.last_integrated_server_version >= b.last_integrated_server_version);
    return (a.last_integrated_server_version == b.last_integrated_server_version);
}

constexpr bool is_session_level_error(ProtocolError error)
{
    return int(error) >= 200 && int(error) <= 299;
}

} // namespace sync
} // namespace realm

#endif // REALM_SYNC_PROTOCOL_HPP