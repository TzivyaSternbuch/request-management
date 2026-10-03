# Starts the backend and the frontend, each in its own PowerShell window.
#   Backend:  https://localhost:60701/swagger  (http://localhost:60702)
#   Frontend: http://localhost:5173            (/api is proxied to the backend)
# Close a window (or press Ctrl+C in it) to stop that process.

$root = $PSScriptRoot

Start-Process powershell -WorkingDirectory "$root\server" -ArgumentList '-NoExit', '-Command', 'dotnet run --project src/Requests.Api'

if (-not (Test-Path "$root\front\node_modules")) {
    npm --prefix "$root\front" install
}
Start-Process powershell -WorkingDirectory "$root\front" -ArgumentList '-NoExit', '-Command', 'npm run dev'
