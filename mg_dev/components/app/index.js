// App.js
import React from "react";
import { HashRouter as Router, Route, Link } from "react-router-dom";
import { hot } from "react-hot-loader";

//ajax
import Axios from "axios";

//Components
import Login from "../login";

//routers
import RouteList from "../../routes";

//css
import "./app.css";
//antd
import { Layout, Menu, Icon, Row, Col } from "antd";
const { SubMenu } = Menu;
const { Header, Content, Sider } = Layout;

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      //是否登陆
      mgLogged: undefined,
      //路由列表
      routes: RouteList.routers,
      //菜单列表
      menuList: RouteList.menu,
      //选中菜单 TODO 刷新无法定位当前页
      defaultSelectedKey: ["1_1"]
    };
  }
  async componentWillMount() {
    const { history } = this.props;
    this.unsubscribeFromHistory = history.listen(this.handleLocationChange);
    this.handleLocationChange(this.props);
    // console.log(this.props);
    const state = {
      mgLogged: false
    };
    // Ajax 查询登陆
    try {
      const res = await Axios.get("/_mg/checkLogin");
      if (res.status === 200) {
        if (res.data.logged === true) {
          state.mgLogged = true;
          this.setState(state);
          return;
        }
      }
      this.setState(state);
    } catch (error) {
      this.setState(state);
    }
  }
  componentWillUnmount() {
    if (this.unsubscribeFromHistory) this.unsubscribeFromHistory();
  }
  handleLocationChange(location) {
    console.log(location);
    // Do something with the location
  }

  render() {
    return (
      <div className="warp">
        {this.state.mgLogged === false && <Login />}
        {this.state.mgLogged === true && (
          <Router>
            <Layout>
              <Header
                className="header"
                style={{ background: "rgba(0,160,233,.7)" }}
              >
                <Row justify="space-between">
                  <Col span={22}>
                    <div
                      className="logo"
                      style={{ backgroundImage: "url('/imgs/logo.png')" }}
                    >
                      <h2 className="title">课程后台管理</h2>
                    </div>
                  </Col>
                  <Col span={2}>
                    <a className="logout" href="">
                      退出
                    </a>
                  </Col>
                </Row>
              </Header>
              <Layout>
                <Sider width={200} style={{ background: "#fff" }}>
                  <Menu
                    mode="inline"
                    defaultSelectedKeys={this.state.defaultSelectedKey}
                    defaultOpenKeys={["1"]}
                    style={{ height: "100%", borderRight: 0 }}
                  >
                    {this.state.menuList.map(
                      (menu, index) =>
                        menu.detail && menu.detail.length > 0 ? (
                          <SubMenu
                            key={menu.key}
                            title={
                              <span>
                                <Icon type={menu.icon} />
                                {menu.title}
                              </span>
                            }
                          >
                            {menu.detail.map((item, index) => (
                              <Menu.Item key={item.key}>
                                <Link to={item.link + "/" + item.key}>
                                  {item.title}
                                </Link>
                              </Menu.Item>
                            ))}
                          </SubMenu>
                        ) : (
                          <Menu.Item key={menu.key}>
                            <Link to={menu.link + "/" + menu.key}>
                              <Icon type={menu.icon} />
                              {menu.title}
                            </Link>
                          </Menu.Item>
                        )
                    )}
                  </Menu>
                </Sider>

                <Layout style={{ padding: "24px" }}>
                  <Content
                    style={{
                      background: "#fff",
                      padding: 24,
                      margin: 0,
                      minHeight: 100
                    }}
                  >
                    <div>
                      {this.state.routes.map((route, index) => (
                        <Route
                          key={index}
                          path={route.path}
                          exact={route.exact}
                          component={route.content}
                        />
                      ))}
                    </div>
                  </Content>
                </Layout>
              </Layout>
            </Layout>
          </Router>
        )}
      </div>
    );
  }
}

export default hot(module)(App);
