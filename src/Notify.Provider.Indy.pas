unit Notify.Provider.Indy;

interface

uses
  System.SysUtils, System.Classes, IdBaseComponent, IdComponent, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdTCPConnection,
  IdTCPClient, IdHTTP, IdStream, IdGlobal, Notify.Provider.Contract;

type
  TNotityProviderIndy = class(TInterfacedObject, INotifyProvider)
  private
    FIOHandlerSSL: TIdSSLIOHandlerSocketOpenSSL;
    FIdHTTP: TIdHTTP;
    FIdEventStream: TIdEventStream;
    procedure OnWriteEvent(const ABuffer: TIdBytes; AOffset, ACount: Longint; var VResult: Longint);
  public
    constructor Create;
    destructor Destroy; override;
    class function New: INotifyProvider;
    function Get: INotifyProvider;
  end;

implementation

{ TNotityProviderIndy }

constructor TNotityProviderIndy.Create;
begin
  FIdHTTP := TIdHTTP.Create(nil);
  FIOHandlerSSL := TIdSSLIOHandlerSocketOpenSSL.Create;
  FIdEventStream := TIdEventStream.Create;

  FIOHandlerSSL.SSLOptions.Method := sslvTLSv1_2;
  FIdHTTP.IOHandler := FIOHandlerSSL;
  FIdHTTP.Request.Accept := 'text/event-stream';
  FIdHTTP.Request.CacheControl := 'no-store';
  FIdHTTP.HTTPOptions := [hoNoReadMultipartMIME, hoNoReadChunked];
  FIdEventStream.OnWrite := OnWriteEvent;

end;

destructor TNotityProviderIndy.Destroy;
begin
  FIdHTTP.Disconnect;
  FIdHTTP.Free;
  FIOHandlerSSL.Free;
  FIdEventStream.Free;
  inherited;
end;

function TNotityProviderIndy.Get: INotifyProvider;
begin
  Result := Self;
  FIdHTTP.Get('');
end;

class function TNotityProviderIndy.New: INotifyProvider;
begin
  Result := Self.Create;
end;

procedure TNotityProviderIndy.OnWriteEvent(const ABuffer: TIdBytes; AOffset,
  ACount: Longint; var VResult: Longint);
begin
  Writeln(IndyTextEncoding_UTF8.GetString(ABuffer));
  Writeln('Response from server: ');
  Writeln(Format('Keep alive: %s', [FIdHTTP.Response.KeepAlive.ToString]));
  Writeln(Format('ResponseText: %s', [FIdHTTP.Response.ResponseText]));
  Writeln(Format('ResponseCode: %s', [FIdHTTP.Response.ResponseCode.ToString]));
  Writeln(Format('ResponseVersion: %s', [Ord(TIdHTTPProtocolVersion(FIdHTTP.Response.ResponseVersion))]));
  Writeln(Format('AcceptPatch: %s', [FIdHTTP.Response.AcceptPatch]));
  Writeln(Format('AcceptRanges: %s', [FIdHTTP.Response.AcceptRanges]));
  Writeln(Format('Location: %s', [FIdHTTP.Response.Location]));
  Writeln(Format('ProxyConnection: %s', [FIdHTTP.Response.ProxyConnection]));
  Writeln(Format('ProxyAuthenticate: %s', [FIdHTTP.Response.ProxyAuthenticate]));
  Writeln(Format('Server: %s', [FIdHTTP.Response.Server]));
  Writeln(Format('RawHeaders: %s', [FIdHTTP.Response.RawHeaders.Text]));
  Writeln(Format('CacheControl: %s', [FIdHTTP.Response.CacheControl]));
  Writeln(Format('CharSet: %s', [FIdHTTP.Response.CharSet]));
  Writeln(Format('Connection: %s', [FIdHTTP.Response.Connection]));
  Writeln(Format('ContentDisposition: %s', [FIdHTTP.Response.ContentDisposition]));
  Writeln(Format('ContentEncoding: %s', [FIdHTTP.Response.ContentEncoding]));
  Writeln(Format('ContentLanguage: %s', [FIdHTTP.Response.ContentLanguage]));
  Writeln(Format('ContentType: %s', [FIdHTTP.Response.ContentType]));
  Writeln(Format('ETag: %s', [FIdHTTP.Response.ETag]));
  Writeln(Format('Pragma: %s', [FIdHTTP.Response.Pragma]));
  Writeln('===================================');
end;

end.
