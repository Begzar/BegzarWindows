# Build Sing-box with clash_api, ... 


## on windows:
run :

```
go mod tidy
```
in ./sing-box-main directory.

then run this command on powershell:
```
// for x32 bit windows 
$Env:GOOS="windows"
$Env:GOARCH="386"  

go build -tags "with_utls,with_clash_api,with_gvisor" -ldflags "-X 'github.com/sagernet/sing-box/constant.Version=1.10.1'" ./cmd/sing-box

=====

// for x64 bit windows
$Env:GOOS="windows"
$Env:GOARCH="amd64"

go build -tags "with_utls,with_clash_api,with_gvisor" -ldflags "-X 'github.com/sagernet/sing-box/constant.Version=1.10.1'" ./cmd/sing-box

=====

// for ARM windows ( new surface & ... )
$Env:GOOS="windows"
$Env:GOARCH="arm64"

go build -tags "with_utls,with_clash_api,with_gvisor" -ldflags "-X 'github.com/sagernet/sing-box/constant.Version=1.10.1'" ./cmd/sing-box
```
Fuck all of your documentions...