//config manage menu
import Category from "./components/category";
import List from "./components/list";
import Activation from "./components/activation";

const RouteList = {
  routers: [
    {
      path: "/",
      exact: true,
      content: Category
    },
    {
      path: "/category/:key",
      content: Category
    },
    {
      path: "/list/:key",
      content: List
    },
    {
      path: "/activation/:key",
      content: Activation
    }
  ],
  menu: [
    {
      title: "管理员管理",
      key: 1,
      icon: "user",
      detail: [
        {
          title: "管理员类别",
          key: "1_1",
          link: "/category"
        },
        {
          title: "管理员列表",
          key: "1_2",
          link: "/list"
        }
      ]
    },
    {
      title: "激活码管理",
      key: 2,
      icon: "laptop",
      link: "/activation"
    }
  ]
};

export default RouteList;
