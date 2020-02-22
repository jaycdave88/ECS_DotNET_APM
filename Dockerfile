FROM microsoft/aspnetcore-build:2.0

COPY . /build
WORKDIR /build
RUN dotnet publish -c Release -o ../out

FROM microsoft/aspnetcore:2.0
WORKDIR /api
COPY --from=0 /build/src/out ./

RUN apt-get update && apt-get install -y bash curl

RUN mkdir -p /opt/datadog
RUN curl -LO https://github.com/DataDog/dd-trace-dotnet/releases/download/v1.13.0/datadog-dotnet-apm_1.13.0_amd64.deb
RUN apt install ./datadog-dotnet-apm_1.13.0_amd64.deb

ENV CORECLR_ENABLE_PROFILING=1
ENV CORECLR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8}
ENV CORECLR_PROFILER_PATH=/opt/datadog/Datadog.Trace.ClrProfiler.Native.so
ENV DD_INTEGRATIONS=/opt/datadog/integrations.json

ENV PORT=80 FORCE_HTTPS=1
EXPOSE 80
CMD ASPNETCORE_URLS="http://*:$PORT" dotnet TodoWebApi.dll
