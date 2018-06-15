import React from "react";
import {
  Table,
  Button,
  Popconfirm,
  Modal,
  Input,
  message,
  Divider,
  Layout,
  Row,
  Col
} from "antd";

//API
import API from "../../API";

//title
import Title from "../title";

//css
import "./index.css";

class List extends React.Component {
  constructor(props) {
    super(props);
    //table
    this.columns = [
      {
        title: "用户名",
        dataIndex: "username",
        key: "username",
        align: "center"
      },
      {
        title: "用户类别",
        dataIndex: "typeName",
        key: "typeName",
        align: "center"
      },
      {
        title: "添加时间",
        dataIndex: "createTime",
        key: "createTime",
        align: "center"
      }
    ];
    this.state = {
      //数据
      listData: [],
      //输入框是否禁用
      nameDisabled: false,
      //输入框的值
      name: "",
      pageSize: 10,
      pageNo: 1,
      totalPage: 0,
      totalCount: 0,
      //筛选选择项
      isActive: "all"
    };
    //监听搜索改变
    this.handleSearchChange = this.handleSearchChange.bind(this);
    // 监听搜索
    this.handleSearch = this.handleSearch.bind(this);
    //页面改变
    this.changePage = this.changePage.bind(this);
    //搜索事件
    this.cateChange = this.cateChange.bind(this);
    // 新增用户
    this.addUser = this.addUser.bind(this);
    //带有复选框的表格
    this.rowSelection = {
      onChange: (selectedRowKeys, selectedRows) => {
        console.log(
          `selectedRowKeys: ${selectedRowKeys}`,
          "selectedRows: ",
          selectedRows
        );
      },
      getCheckboxProps: record => ({})
    };
  }
  //管理员搜索框改变事件
  handleSearchChange(e) {
    this.setState({
      name: e.target.value
    });
  }
  //管理员搜索
  async handleSearch(name) {
    const params = {
      pageSize: 10,
      pageNo: 1
    };
    if (name) {
      params.key = name;
    }
    const res = await API.getAdminList(params);
    if (res.err === 0) {
      if (!(res.data instanceof Array)) {
        this.setState({
          listData: []
        });
      } else {
        this.setState({
          listData: res.data
        });
      }
      this.setState({
        pageSize: res.page.pageSize,
        pageNo: res.page.pageNo,
        totalPage: res.page.totalPage,
        totalCount: res.page.totalCount
      });
    }
  }
  //类别筛选
  async cateChange(cate) {
    const params = {
      pageSize: 10,
      pageNo: 1
    };
    if (cate === "admin" || cate === "mag") {
      params.key = cate;
    }
    this.setState({
      isActive: cate
    });
    const res = await API.getAdminList(params);
    if (res.err === 0) {
      if (!(res.data instanceof Array)) {
        this.setState({
          listData: []
        });
      } else {
        this.setState({
          listData: res.data
        });
      }
      this.setState({
        pageSize: res.page.pageSize,
        pageNo: res.page.pageNo,
        totalPage: res.page.totalPage,
        totalCount: res.page.totalCount
      });
    }
  }
  // 添加管理员类别
  addUser() {
    this.setState({
      visible: true
    });
  }
  //翻页
  async changePage(page, pageSize) {
    await API.getAdminList({ pageNo: page, pageSize: pageSize });
  }
  //获取当前类别列表
  async componentWillMount() {
    const res = await API.getAdminList();
    if (res.err === 0) {
      if (res.data instanceof Array) {
        this.setState({
          listData: res.data
        });
      } else {
        this.setState({
          listData: []
        });
      }
      this.setState({
        listData: res.data,
        pageSize: res.page.pageSize,
        pageNo: res.page.pageNo,
        totalPage: res.page.totalPage,
        totalCount: res.page.totalCount
      });
    } else if (res.err === 102) {
      console.log("未登录");
    }
  }
  render() {
    const columns = this.columns;
    const {
      nameDisabled,
      name,
      pageNo,
      totalPage,
      pageSize,
      changePage,
      listData,
      totalCount,
      isActive,
      visible
    } = this.state;
    return (
      <div>
        <Title
          title="管理员列表"
          titleBtn={[
            {
              type: "primary",
              btnTitle: "添加",
              clickEvent: () => this.addUser()
            },
            {
              btnTitle: "打印",
              clickEvent: () => this.printUser()
            }
          ]}
        />
        <Row gutter={16}>
          <Col span={5}>
            <Input
              placeholder="请输入类别名称"
              disabled={nameDisabled}
              value={name}
              onChange={this.handleSearchChange}
            />
          </Col>
          <Col span={5}>
            <Button onClick={() => this.handleSearch(name)}>搜索</Button>
          </Col>
        </Row>
        <Divider />
        <div className="sort">
          <span style={{ marginRight: "10px" }}>类别：</span>
          <a
            style={{ marginRight: "10px" }}
            href="javascript:;"
            className={isActive === "all" ? "active" : "unactive"}
            onClick={() => this.cateChange("all")}
          >
            全部
          </a>
          <a
            style={{ marginRight: "10px" }}
            href="javascript:;"
            className={isActive === "admin" ? "active" : "unactive"}
            onClick={() => this.cateChange("admin")}
          >
            超级管理员
          </a>
          <a
            href="javascript:;"
            className={isActive === "mag" ? "active" : "unactive"}
            onClick={() => this.cateChange("mag")}
          >
            管理员
          </a>
        </div>
        <Divider />

        <div className="total" style={{ marginBottom: "10px" }}>
          共 {totalCount} 条：
        </div>
        <Table
          rowSelection={this.rowSelection}
          rowKey={record => record.sn}
          columns={columns}
          dataSource={listData}
          hideOnSinglePage
          Pagination={{
            defaultCurrent: pageNo,
            total: totalPage,
            pageSize: pageSize,
            onChange: changePage
          }}
        />
      </div>
    );
  }
}

export default List;
