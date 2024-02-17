import * as vg from "npm:@uwdata/vgplot@0.5.0";

export function url(path) {
  const u = new URL('_file/' + path, window.location).toString();
  console.error(u);
  return u;
}

export async function vgplot(queries) {
  const mc = vg.coordinator();
  console.log('CREATING A NEW API CONTEXT');
  const api = vg.createAPIContext({ coordinator: mc });
  mc.databaseConnector(vg.wasmConnector());
  if (queries?.length) {
    await mc.exec(queries.map(q => q(api)));
  }
  return api;
}
