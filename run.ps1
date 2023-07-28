# Activate the virtual environment (assuming it's called 'env')
.\env\Scripts\Activate

# Stop the previous process using 'stop.sh' (assuming it's a bash script)
.\stop.ps1

# Start the Gunicorn server
Start-Process -NoNewWindow -FilePath "gunicorn" -ArgumentList "--bind", "0.0.0.0:5000", "--worker-class", "eventlet", "-w", "1", "--threads", "1", "OvenSpace:app" -RedirectStandardOutput "OvenSpace.log" -RedirectStandardError "OvenSpace.log"
