require 'socket'

def handle_client(client)
  client.puts "Connected to Server"
  loop do
    message = client.gets

    if message.nil? || message == "q\\n"
      puts "Client disconnected"
      break
    end

    puts "Received message from client: #{message}"

    client.puts "Server received your message: #{message}"
  end

  # Close the connection with the client when the loop ends
  client.close
end

port = 8800
server = TCPServer.new(port)
puts "Server listening on port #{port}..."

# Limit the number of simultaneous connections
max_connections = 2
current_connections = 0
mutex = Mutex.new

loop do
  # Wait until there is an available slot for a new connection
  mutex.synchronize do
    while current_connections >= max_connections
      puts "Connection limit reached. Waiting for a slot..."
      mutex.sleep(1)  # Sleep for 1 second (adjust as needed)
    end
  end

  client = server.accept

  # Increment the connection count
  mutex.synchronize { current_connections += 1 }

  # Start a new thread to handle the client
  Thread.new do
    # Wait until there is an available slot for a new connection
    handle_client(client)

    # Decrement the connection count when the client disconnects
    mutex.synchronize { current_connections -= 1 }

  end
end

