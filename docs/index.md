# Mosaic + Framework Examples

[Mosaic](https://uwdata.github.io/mosaic) is a system for linking data visualizations, tables, and input widgets, all leveraging a database for scalable processing. With Mosaic, you can interactively visualize and explore millions and even billions of data points.

A key idea is that interface elements (Mosaic _clients_) publish their data needs as queries that are managed by a central _coordinator_. The coordinator may further optimize queries before issuing them to a backing _data source_ such as [DuckDB](https://duckdb.org/).

This site shares examples of integrating Mosaic and DuckDB data loaders into Observable Framework. Source code is available at <https://github.com/uwdata/mosaic-framework-example>.

## Example Data Apps

- [Flight Delays](/flight-delays) - explore over 200,000 flight records
- [NYC Taxi Rides](/nyc-taxi-rides) - load and visualize 1M NYC taxi cab rides
- [Observable Latency](/observable-latency) - a dense view of over 7M web requests

## Implementation Notes

- _Using DuckDB in data loaders and GitHub Actions_
- _Using Mosaic + DuckDB-WASM in Observable Framework_
