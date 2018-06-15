import React from "react";
import { Table, Button, Popconfirm, Modal, Input, message } from "antd";

//API
import API from "../../API";

//title
import Title from "../title";

class Category extends React.Component {
  constructor(props) {
    super(props);
    //table
    this.columns = [
      {
        title: "序号",
        dataIndex: "index",
        key: "index",
        align: "center",
        render: (text, record, index) => (
          <span>
            <span>{index + 1}</span>
          </span>
        )
      },
      {
        title: "类别名称",
        dataIndex: "name",
        key: "name",
        align: "center"
      },
      {
        title: "添加时间",
        dataIndex: "createTime",
        key: "createTime",
        align: "center"
      }
      // 暂不需要删除
      // {
      //   title: "操作",
      //   key: "action",
      //   align: "center",
      //   render: (text, record) => {
      //     return (
      //       <span>
      //         {record.state === 1 ? (
      //           this.state.CategoryData.length > 1 ? (
      //             <Popconfirm
      //               title="Sure to delete?"
      //               onConfirm={() => this.onDelete(record.id)}
      //             >
      //               <Button type="danger">删除</Button>
      //             </Popconfirm>
      //           ) : null
      //         ) : (
      //           "/"
      //         )}
      //       </span>
      //     );
      //   }
      // }
    ];

    this.state = {
      //数据
      CategoryData: [],
      // 输入框提交时是否禁用
      nameDisabled: false,
      //是否显示新增类别弹窗
      visible: false,
      //弹窗提交加载中
      confirmLoading: false,
      //输入框名称
      typeName: "",
      pageSize: 10,
      pageNo: 1,
      totalPage: 0
    };
    //新增用户
    this.addManager = this.addManager.bind(this);
    //暂时没有
    this.onDelete = this.onDelete.bind(this);
    //关闭新增
    this.handleUpdateCancel = this.handleUpdateCancel.bind(this);
    //确认新增
    this.handleUpdateOk = this.handleUpdateOk.bind(this);
    //新增类别输入框改变事件
    this.handleTypeNameChange = this.handleTypeNameChange.bind(this);
    //监听页面改变
    this.changePage = this.changePage.bind(this);
  }

  //删除管理员类别
  onDelete(id) {
    const dataSource = [...this.state.CategoryData];
    this.setState({ CategoryData: dataSource.filter(item => item.id !== id) });
  }
  // 添加管理员类别
  addManager() {
    this.setState({
      visible: true
    });
  }
  //输入框监听事件
  handleTypeNameChange(e) {
    this.setState({ typeName: e.target.value, errorVisible: false });
  }
  //确认添加
  async handleUpdateOk() {
    if (this.state.typeName !== "") {
      this.setState({
        nameDisabled: true,
        confirmLoading: true
      });
      const res = await API.postUpsertType({ name: this.state.typeName });
      if (res.err === 0) {
        const list = this.state.CategoryData;
        list.push({
          sn: res.sn,
          createTime: "刚刚",
          state: 1,
          name: this.state.typeName
        });
        this.setState({
          visible: false,
          confirmLoading: false,
          CategoryData: list
        });
      } else {
        message.error(res.msg);
      }
    } else {
      message.error("请输入类别名称");
    }
  }
  //取消添加
  handleUpdateCancel() {
    this.setState({
      visible: false
    });
  }
  //翻页
  async changePage(page, pageSize) {
    await API.getAdminTypeList({ pageNo: page, pageSize: pageSize });
  }
  //获取当前类别列表
  async componentWillMount() {
    const res = await API.getAdminTypeList();

    this.setState({
      CategoryData: res.data,
      pageSize: res.page.pageSize,
      pageNo: res.page.pageNo,
      totalPage: res.page.totalPage
    });
  }
  render() {
    const columns = this.columns;
    const {
      visible,
      confirmLoading,
      nameDisabled,
      typeName,
      pageSize,
      pageNo,
      totalPage,
      changePage
    } = this.state;
    return (
      <div>
        <Title
          title="管理员类别"
          titleBtn={[
            {
              type: "primary",
              btnTitle: "添加",
              clickEvent: () => this.addManager()
            }
          ]}
        />
        <Table
          rowKey={record => record.sn}
          columns={columns}
          dataSource={this.state.CategoryData}
          hideOnSinglePage
          Pagination={{
            defaultCurrent: pageNo,
            total: totalPage,
            pageSize: pageSize,
            onChange: changePage
          }}
        />
        <Modal
          title="添加类别"
          visible={visible}
          onOk={this.handleUpdateOk}
          confirmLoading={confirmLoading}
          onCancel={this.handleUpdateCancel}
        >
          <p>
            <Input
              placeholder="请输入类别名称"
              disabled={nameDisabled}
              value={typeName}
              onChange={this.handleTypeNameChange}
            />
          </p>
        </Modal>
      </div>
    );
  }
}

export default Category;
