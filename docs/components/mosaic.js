import * as vg from "npm:@uwdata/vgplot@0.5.0";

export function url(file) {
  const url = new URL(file, window.location);
  console.log('??', url);
  return `${url}`;
}

export async function vgplot(queries) {
  const mc = vg.coordinator();
  const api = vg.createAPIContext({ coordinator: mc });
  mc.databaseConnector(vg.wasmConnector());
  if (queries) {
    await mc.exec(queries(api));
  }
  return api;
}
