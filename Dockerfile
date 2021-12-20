# Setup Environment
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
	&& apt update \
	&& apt install -y nodejs
WORKDIR /app

# Copy csproj and restore
ARG RTT_Token=[INSERT_REALTIMETRAINS_TOKEN_HERE]

COPY ./ ./
WORKDIR /app/DepartureBoardWeb/
RUN dotnet restore

#Setup Ng
WORKDIR /app/DepartureBoardWeb/ClientApp
RUN npm link @angular/cli
RUN npm install

# Copy everything else and build
WORKDIR /app/DepartureBoardWeb/
RUN dotnet publish -c Release -o /app/DepartureBoardWeb/deploy
#Creates config file
RUN echo "<Config><RealTimeTrainsToken>$RTT_Token</RealTimeTrainsToken></Config>" > /app/DepartureBoardWeb/deploy/config.xml

# Generate runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
COPY --from=build-env /app/DepartureBoardWeb/deploy .
EXPOSE 80
ENTRYPOINT ["dotnet", "DepartureBoardWeb.dll"]
