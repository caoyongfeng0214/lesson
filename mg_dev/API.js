//API
import Axios from "axios";
import qs from "qs";

const APIPATH = "http://localhost:3000";

const Client = Axios.create({
  baseURL: APIPATH
});

const API = {
  postUpsertType: postUpsertType,
  getAdminTypeList: getAdminTypeList,
  getAdminList: getAdminList
};
//添加类型
async function postUpsertType(params) {
  const res = await Client.post(
    "/api/_mg/admin/upsertType",
    qs.stringify(params)
  );
  return res.data;
}
//获取类型列表
async function getAdminTypeList(params) {
  const res = await Client.get("/api/_mg/admin/typeList", params);
  return res.data;
}
//管理员列表
async function getAdminList(params) {
  const res = await Client.get("/api/_mg/admin/list", {
    params: params
  });
  return res.data;
}

export default API;
