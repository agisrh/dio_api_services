/// HTTP 100 Continue
const status100Continue = 100;

/// HTTP 101 Switching Protocols
const status101SwitchingProtocols = 101;

/// HTTP 102 Processing
const status102Processing = 102;

/// HTTP 200 OK
const status200OK = 200;

/// HTTP 201 Created
const status201Created = 201;

/// HTTP 202 Accepted
const status202Accepted = 202;

/// HTTP 203 Non-Authoritative Information
const status203NonAuthoritative = 203;

/// HTTP 204 No Content
const status204NoContent = 204;

/// HTTP 205 Reset Content
const status205ResetContent = 205;

/// HTTP 206 Partial Content
const status206PartialContent = 206;

/// HTTP 207 Multi-Status
const status207Multistatus = 207;

/// HTTP 208 Already Reported
const status208AlreadyReported = 208;

/// HTTP 226 IM Used
const status226IMUsed = 226;

/// HTTP 300 Multiple Choices
const status300MultipleChoices = 300;

/// HTTP 301 Moved Permanently
const status301MovedPermanently = 301;

/// HTTP 302 Found
const status302Found = 302;

/// HTTP 303 See Other
const status303SeeOther = 303;

/// HTTP 304 Not Modified
const status304NotModified = 304;

/// HTTP 305 Use Proxy
const status305UseProxy = 305;

/// HTTP 306 Switch Proxy
const status306SwitchProxy = 306; // RFC 2616, removed

/// HTTP 307 Temporary Redirect
const status307TemporaryRedirect = 307;

/// HTTP 308 Permanent Redirect
const status308PermanentRedirect = 308;

/// HTTP 400 Bad Request
const status400BadRequest = 400;

/// HTTP 401 Unauthorized
const status401Unauthorized = 401;

/// HTTP 402 Payment Required
const status402PaymentRequired = 402;

/// HTTP 403 Forbidden
const status403Forbidden = 403;

/// HTTP 404 Not Found
const status404NotFound = 404;

/// HTTP 405 Method Not Allowed
const status405MethodNotAllowed = 405;

/// HTTP 406 Not Acceptable
const status406NotAcceptable = 406;

/// HTTP 407 Proxy Authentication Required
const status407ProxyAuthenticationRequired = 407;

/// HTTP 408 Request Timeout
const status408RequestTimeout = 408;

/// HTTP 409 Conflict
const status409Conflict = 409;

/// HTTP 410 Gone
const status410Gone = 410;

/// HTTP 411 Length Required
const status411LengthRequired = 411;

/// HTTP 412 Precondition Failed
const status412PreconditionFailed = 412;

/// HTTP 413 Request Entity Too Large (RFC 2616)
const status413RequestEntityTooLarge = 413; // RFC 2616, renamed

/// HTTP 413 Payload Too Large (RFC 7231)
const status413PayloadTooLarge = 413; // RFC 7231

/// HTTP 414 Request-URI Too Long (RFC 2616)
const status414RequestUriTooLong = 414; // RFC 2616, renamed

/// HTTP 414 URI Too Long (RFC 7231)
const status414UriTooLong = 414; // RFC 7231

/// HTTP 415 Unsupported Media Type
const status415UnsupportedMediaType = 415;

/// HTTP 416 Requested Range Not Satisfiable (RFC 2616)
const status416RequestedRangeNotSatisfiable = 416; // RFC 2616, renamed

/// HTTP 416 Range Not Satisfiable (RFC 7233)
const status416RangeNotSatisfiable = 416; // RFC 7233

/// HTTP 417 Expectation Failed
const status417ExpectationFailed = 417;

/// HTTP 418 I'm a teapot
const status418ImATeapot = 418;

/// HTTP 419 Authentication Timeout
const status419AuthenticationTimeout = 419; // Not defined in any RFC

/// HTTP 421 Misdirected Request
const status421MisdirectedRequest = 421;

/// HTTP 422 Unprocessable Entity
const status422UnprocessableEntity = 422;

/// HTTP 423 Locked
const status423Locked = 423;

/// HTTP 424 Failed Dependency
const status424FailedDependency = 424;

/// HTTP 426 Upgrade Required
const status424UpgradeRequired = 426;

/// HTTP 428 Precondition Required
const status428PreconditionRequired = 428;

/// HTTP 429 Too Many Requests
const status429TooManyRequests = 429;

/// HTTP 431 Request Header Fields Too Large
const status431RequestHeaderFieldsTooLarge = 431;

/// HTTP 451 Unavailable For Legal Reasons
const status451UnavailableForLegalReasons = 451;

/// HTTP 500 Internal Server Error
const status500InternalServerError = 500;

/// HTTP 501 Not Implemented
const status501NotImplemented = 501;

/// HTTP 502 Bad Gateway
const status502BadGateway = 502;

/// HTTP 503 Service Unavailable
const status503ServiceUnavailable = 503;

/// HTTP 504 Gateway Timeout
const status504GatewayTimeout = 504;

/// HTTP 505 HTTP Version Not Supported
const status505HttpVersionNotSupported = 505;

/// HTTP 506 Variant Also Negotiates
const status506VariantAlsoNegotiates = 506;

/// HTTP 507 Insufficient Storage
const status507InsufficientStorage = 507;

/// HTTP 508 Loop Detected
const status508LoopDetected = 508;

/// HTTP 510 Not Extended
const status510NotExtended = 510;

/// HTTP 511 Network Authentication Required
const status511NetworkAuthenticationRequired = 511;

/// Cloudflare: Web Server Returned Unknown Error
const status520WebServerReturnedUnknownError = 520;

/// Cloudflare: Web Server Is Down
const status521WebServerIsDown = 521;

/// Cloudflare: Connection Timed Out
const status522ConnectionTimedOut = 522;

/// Cloudflare: Origin Is Unreachable
const status523OriginIsUnreachable = 523;

/// Cloudflare: Timeout Occurred
const status524TimeoutOccurred = 524;

/// Cloudflare: SSL Handshake Failed
const status525SSLHandshakeFailed = 525;

/// Cloudflare: Invalid SSL Certificate
const status526InvalidSSLCertificate = 526;

/// Cloudflare: Railgun Error
const status527RailgunError = 527;

/// Network Read Timeout Error (Not in RFC)
const status598NetworkReadTimeoutError = 598;

/// Network Connect Timeout Error (Not in RFC)
const status599NetworkConnectTimeoutError = 599;

/// IIS: Login Timeout
const status440LoginTimeout = 440;

/// Nginx: Client Closed Request
const status499ClientClosedRequest = 499;

/// AWS ELB: Client Closed Request
const status460ClientClosedRequest = 460;

/// Set of HTTP status codes that are considered retryable by default.
const defaultRetryableStatuses = <int>{
  status408RequestTimeout,
  status429TooManyRequests,
  status500InternalServerError,
  status502BadGateway,
  status503ServiceUnavailable,
  status504GatewayTimeout,
  status440LoginTimeout,
  status499ClientClosedRequest,
  status460ClientClosedRequest,
  status598NetworkReadTimeoutError,
  status599NetworkConnectTimeoutError,
  status520WebServerReturnedUnknownError,
  status521WebServerIsDown,
  status522ConnectionTimedOut,
  status523OriginIsUnreachable,
  status524TimeoutOccurred,
  status525SSLHandshakeFailed,
  status527RailgunError,
};

/// Deprecated version of [defaultRetryableStatuses].
@Deprecated('Use [defaultRetryableStatuses]')
const retryableStatuses = defaultRetryableStatuses;

/// Utility function to check if a status code is in the default retryable list.
bool isRetryable(int statusCode) =>
    defaultRetryableStatuses.contains(statusCode);
