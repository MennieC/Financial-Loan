# Financial Loan Data Analysis & Power BI Dashboard

> MySQL 数据分析 + Power BI 数据建模 + DAX 动态指标，通过贷款规模、资金回收、贷款质量和客户结构等维度分析金融贷款业务表现。

---

## 📊 Dashboard Preview

| 1. Loan Summary                          | 2. Loan Overview                           |
| ---------------------------------------- | ------------------------------------------ |
| ![Loan Summary](screenshots/summary.png) | ![Loan Overview](screenshots/overview.png) |

---

# 一、项目简介

本项目基于金融贷款业务数据，使用 **MySQL + Power BI + DAX** 对贷款申请、放款金额、回款金额、利率、债务收入比以及贷款状态等指标进行分析，并搭建交互式贷款业务 Dashboard。

分析主要围绕三个业务问题展开：

1. **业务规模如何变化？**
   通过贷款申请量、放款金额、回款金额以及 MTD / MoM 指标监控业务规模及月度变化。

2. **当前贷款资产质量如何？**
   根据贷款状态划分 Good Loan 与 Bad Loan，对比贷款数量、放款金额和回款金额。

3. **贷款业务主要由哪些客户和需求构成？**
   从地区、贷款期限、就业年限、贷款用途等维度分析贷款业务结构，为客户分层、产品设计和风险管理提供参考。

最终建立 **Summary + Overview** 两层 Power BI 分析体系：

> **核心 KPI → 贷款质量 → 时间趋势 → 客户与业务结构**

---

# 二、技术栈

| 工具              | 用途                                  |
| --------------- | ----------------------------------- |
| **MySQL**       | 数据查询、业务指标计算与结果验证                    |
| **DBeaver**     | 数据库连接、SQL 查询及数据检查                   |
| **Power BI**    | 数据建模与交互式 Dashboard                  |
| **Power Query** | 字段类型处理及数据整理                         |
| **DAX**         | KPI、MTD、MoM、Good / Bad Loan 等动态指标计算 |

---

# 三、核心数据字段

数据主要包含贷款申请信息、客户属性、贷款状态及资金表现。

| 字段               | 业务含义   |
| ---------------- | ------ |
| `id`             | 贷款申请编号 |
| `issue_date`     | 贷款发放日期 |
| `loan_amount`    | 贷款金额   |
| `total_payment`  | 累计回款金额 |
| `int_rate`       | 贷款利率   |
| `dti`            | 债务收入比  |
| `loan_status`    | 贷款状态   |
| `term`           | 贷款期限   |
| `address_state`  | 客户所在地区 |
| `emp_length`     | 就业年限   |
| `purpose`        | 贷款用途   |
| `annual_income`  | 客户年收入  |
| `home_ownership` | 住房情况   |

---

# 四、数据模型

Power BI 模型主要由两张核心表构成：

### financial_loan

贷款业务事实表，保存贷款申请、客户属性、贷款状态和资金信息。

### Date Table

独立日期维度表，与 `financial_loan` 中的贷款发放日期建立关联，用于计算：

* MTD（Month-to-Date）
* 上月指标
* MoM（Month-over-Month）
* 月度趋势

通过日期维度表而不是直接使用事实表日期，可以统一时间分析口径，并支持后续扩展 YTD、同比等时间智能指标。

---

# 五、核心 KPI

Summary 页面首先建立贷款业务的核心指标体系。

## 1. Total Loan Applications

贷款申请总量：

```DAX
Total Loan Applications =
COUNT(financial_loan[id])
```

用于衡量贷款业务整体规模。

---

## 2. Total Funded Amount

累计放款金额：

```DAX
Total Funded Amount =
SUM(financial_loan[loan_amount])
```

反映金融机构实际投放的贷款资金规模。

---

## 3. Total Amount Received

累计回款金额：

```DAX
Total Amount Received =
SUM(financial_loan[total_payment])
```

用于观察贷款资金回收表现。

---

## 4. Average Interest Rate

```DAX
Avg Interest Rate =
AVERAGE(financial_loan[int_rate])
```

反映当前贷款组合整体利率水平。

---

## 5. Average DTI

```DAX
Avg DTI =
AVERAGE(financial_loan[dti])
```

DTI（Debt-to-Income Ratio）反映借款人债务负担与收入之间的比例，是观察借款人偿债压力的重要指标之一。

---

# 六、MTD 与 MoM 时间分析

仅观察累计值无法判断近期业务是否增长，因此进一步建立 MTD 与 MoM 指标。

### MTD Loan Applications

```DAX
MTD Loan Applications =
TOTALMTD(
    [Total Loan Applications],
    'Date Table'[Date]
)
```

表示当前筛选月份截至当前日期累计产生的贷款申请量。

同样的方法计算：

* `MTD Funded Amount`
* `MTD Total Amount Received`

进一步建立 MoM 指标，对当前月份与上一月份的表现进行比较。

例如：

```text
MoM Growth
= (Current Month - Previous Month)
  / Previous Month
```

从而将 Dashboard 从单纯的“累计结果展示”扩展为：

> **当前业务规模 + 当前月份表现 + 月度变化趋势**

---

# 七、Good Loan / Bad Loan 贷款质量分析

为了分析贷款组合质量，根据 `loan_status` 对贷款进行业务分类。

### Good Loan

包括：

* Fully Paid
* Current

表示已经完成还款或当前仍处于正常还款状态的贷款。

### Bad Loan

包括：

* Charged Off

表示已经发生严重违约并形成损失的贷款。

---

## Good Loan Applications

```DAX
Good Loan Applications =
CALCULATE(
    [Total Loan Applications],
    financial_loan[Good VS Bad Loan] = "Good Loan"
)
```

## Good Loan %

```DAX
Good Loan % =
DIVIDE(
    [Good Loan Applications],
    [Total Loan Applications],
    0
)
```

Dashboard 同时分析：

| Good Loan       | Bad Loan        |
| --------------- | --------------- |
| Applications    | Applications    |
| Application %   | Application %   |
| Funded Amount   | Funded Amount   |
| Amount Received | Amount Received |

这样可以同时从**贷款笔数和资金金额**两个角度观察贷款质量，而不是只看贷款申请规模。

---

# 八、Overview 多维业务分析

Overview 页面进一步拆解贷款业务结构，并通过动态指标实现不同业务指标之间的切换分析。

## 1. Monthly Trend

按照贷款发放月份分析业务变化趋势。

可观察：

* 贷款申请量变化
* 放款金额变化
* 回款金额变化
* 不同月份业务规模差异

该分析用于判断贷款业务是否存在明显的增长、下降或季节性变化。

---

## 2. Regional Analysis

按照 `address_state` 分析不同地区的贷款业务分布。

用于识别：

* 贷款需求集中地区
* 不同地区业务规模差异
* 潜在的区域市场集中度

需要注意：

> 地区贷款量较高并不直接代表地区风险较高。

如果要判断地区风险，还需要进一步结合 Bad Loan Rate、DTI、收入和贷款金额等指标。

---

## 3. Loan Term Analysis

按照 `term` 比较不同贷款期限的业务结构。

例如：

* 36 months
* 60 months

贷款期限会影响客户月度还款压力、利息支出以及金融机构的资金占用周期，因此是贷款产品结构分析的重要维度。

---

## 4. Employment Length Analysis

按照 `emp_length` 分析不同就业年限客户的贷款业务规模。

就业年限可以一定程度反映客户职业稳定性，但不能单独作为信用风险判断依据。

因此该指标更适合作为客户画像变量，并与：

* DTI
* Annual Income
* Loan Amount
* Loan Status

结合分析。

---

## 5. Loan Purpose Analysis

按照 `purpose` 分析客户贷款用途。

数据中的贷款用途包括债务整合、信用卡、住房改善、个人消费等不同需求。

该维度能够帮助回答：

> **客户为什么借款？**

进一步结合贷款状态后，可以用于判断不同贷款用途对应的业务规模和潜在风险差异。

---

# 九、Dashboard 设计逻辑

## Page 1 — Summary

回答：

> **目前贷款业务整体表现如何？**

主要展示：

**Applications → Funded Amount → Amount Received → Interest Rate → DTI**

并进一步通过：

**Good Loan VS Bad Loan**

观察贷款组合质量。

---

## Page 2 — Overview

回答：

> **贷款业务主要由哪些地区、产品和客户需求构成？**

从以下维度进行拆解：

**Month → State → Term → Employment Length → Purpose**

并支持在不同核心指标之间进行动态切换。

因此整个 Dashboard 的分析逻辑为：

> **整体业务表现
> ↓
> 贷款质量
> ↓
> 时间变化
> ↓
> 地区与产品结构
> ↓
> 客户需求结构**

---

# 十、主要业务发现

基于当前 Dashboard 的指标体系，可以形成以下几类业务发现。

### 1. 业务规模不能单独代表经营质量

贷款申请量和放款金额能够反映业务扩张程度，但如果只追求贷款规模，可能忽略资产质量。

因此 Dashboard 将：

**Total Applications / Funded Amount**

与：

**Good Loan / Bad Loan**

放在同一分析体系中。

这意味着贷款业务评估不能只回答：

> “放出了多少钱？”

还需要回答：

> “这些贷款最终表现怎么样？”

---

### 2. 回款金额需要与放款金额联合分析

`Total Funded Amount` 反映资金投放规模，而 `Total Amount Received` 反映资金回收结果。

两者结合比单独观察贷款申请量更能反映贷款业务的资金表现。

但需要注意：

> `Total Amount Received / Total Funded Amount` 不能直接解释为最终回收率。

因为部分贷款可能仍处于 Current 状态，贷款期限和观察窗口也会影响累计回款金额。

---

### 3. Good / Bad Loan 应同时观察数量和金额

Bad Loan Application % 可以反映问题贷款在贷款笔数中的比例，但如果不同贷款金额差异较大，仅观察贷款数量可能低估资金风险。

因此需要同时关注：

* Bad Loan Applications
* Bad Loan %
* Bad Loan Funded Amount
* Bad Loan Amount Received

从“笔数风险”和“资金风险”两个角度评价贷款组合。

---

### 4. 贷款需求具有明显的业务场景差异

`purpose` 可以帮助识别客户的主要融资需求。

不同贷款用途对应的客户资金需求和偿债能力可能不同，因此可以进一步构建：

> Purpose × Bad Loan Rate
> Purpose × Avg DTI
> Purpose × Avg Interest Rate

判断哪些贷款用途属于：

* 高需求、低风险
* 高需求、高风险
* 低需求、低风险
* 低需求、高风险

从而支持贷款产品和审批策略优化。

---

### 5. 客户结构变量需要联合分析

就业年限、地区、贷款期限等变量本身只能描述贷款业务结构。

例如：

> 某就业年限客户贷款申请最多

并不能直接推出：

> 该客户群风险最低。

因此风险判断应进一步结合：

**Loan Status + DTI + Income + Loan Amount + Interest Rate**

避免仅根据单一客户特征做风险判断。

---

# 十一、业务建议

## 1. 从“贷款规模监控”升级为“规模 + 风险”双指标体系

当前 Dashboard 已经建立申请量、放款金额和 Good / Bad Loan 指标。

实际业务中建议将：

**Loan Growth**

与：

**Bad Loan Rate**

进行联合监控。

例如：

> 如果某个月贷款申请量快速增长，同时 Bad Loan Rate 也明显上升，则需要检查业务增长是否来自审批标准放宽或高风险客户增加。

因此业务增长不应单独作为正向指标。

---

## 2. 建立贷款用途风险矩阵

以 `purpose` 为核心维度，同时分析：

* Loan Applications
* Funded Amount
* Bad Loan Rate
* Avg DTI
* Avg Interest Rate

将不同贷款用途划分为不同风险等级。

对于：

> **高申请量 + 高 Bad Loan Rate**

的贷款用途，可以进一步：

* 加强收入与负债核验；
* 调整审批规则；
* 设置更严格的 DTI 阈值；
* 优化贷款额度；
* 加强贷后监控。

---

## 3. 对高 DTI 客户进行分层管理

DTI 是反映客户偿债压力的重要变量。

建议进一步建立 DTI 分箱，例如：

```text
Low DTI
Medium DTI
High DTI
Very High DTI
```

然后比较不同 DTI 区间的：

* Bad Loan Rate
* Avg Loan Amount
* Avg Interest Rate
* Amount Received

如果高 DTI 客户的 Bad Loan Rate 明显升高，则可以将 DTI 作为风险预警和审批策略的重要参考变量。

---

## 4. 联合分析贷款期限与风险

36 个月和 60 个月贷款不仅代表不同产品期限，也对应不同的还款压力和资金占用周期。

建议进一步建立：

> Term × Bad Loan Rate
> Term × Avg Loan Amount
> Term × Avg DTI
> Term × Interest Rate

判断较长期限贷款是否伴随更高的信用风险。

如果长期贷款在某些客户群体中表现较差，可考虑：

* 调整授信额度；
* 优化期限选择规则；
* 根据客户风险水平匹配贷款期限。

---

## 5. 从区域业务规模扩展到区域风险分析

当前 Overview 可以展示不同州的贷款业务规模。

下一步不应简单把“贷款最多的州”理解为重点风险地区，而应该进一步计算：

```text
State Bad Loan Rate
= State Bad Loan Applications
  / State Total Loan Applications
```

结合：

* Funded Amount
* Bad Loan Rate
* Avg DTI
* Avg Interest Rate

建立区域业务矩阵。

这样可以区分：

> **高规模 + 低风险地区**

和：

> **高规模 + 高风险地区**

从而支持区域营销和风险策略制定。

---

## 6. 增加贷后风险监控

目前 Dashboard 主要分析历史贷款结果。

后续可以进一步加入：

* 逾期天数
* 分期还款记录
* 剩余本金
* 最近还款日期
* 历史逾期次数

建立贷后监控体系。

如果数据条件允许，可以进一步构建：

> **客户画像 → 风险指标 → 贷款状态 → 违约概率**

形成从 BI 描述性分析向信用风险预测的扩展。

---

# 十二、数据边界与分析注意事项

1. **Good Loan 不等于最终无风险。**
   `Current` 贷款仍处于还款过程中，其最终状态尚未确定。

2. **累计回款金额不能直接作为最终回收率。**
   不同贷款的发放时间和期限不同，观察窗口会影响累计回款金额。

3. **地区、就业年限和贷款用途属于描述性特征。**
   单一变量不能直接解释贷款违约原因。

4. **相关性不代表因果关系。**
   如果某类客户 Bad Loan Rate 较高，只能说明数据中存在关联，不能直接认定该客户特征导致违约。

5. **当前 Dashboard 以描述性 BI 分析为主。**
   尚未建立 PD（Probability of Default）等信用风险预测模型，因此不应将 Dashboard 指标解释为客户未来违约概率。

---

# 十三、项目结构

```text
financial_loan_analysis/
│
├── data/
│   └── financial_loan.csv
│
├── sql/
│   └── financial_loan_analysis.sql
│
├── powerbi/
│   └── bank_data_lineplot.pbix
│
├── screenshots/
│   ├── summary.png
│   └── overview.png
│
└── README.md
```

---

# 十四、项目总结

本项目基于金融贷款业务数据，通过 **MySQL + Power BI + DAX** 建立贷款业务分析 Dashboard。

项目从：

**贷款申请规模 → 资金投放与回收 → Good / Bad Loan → 时间趋势 → 地区 → 贷款期限 → 就业年限 → 贷款用途**

逐层拆解贷款业务表现。

相比单纯制作可视化图表，本项目重点建立了明确的业务指标体系，并尝试将分析结果转化为：

* 贷款业务规模监控
* 贷款质量分析
* 客户结构分析
* 产品结构优化
* 风险分层管理

等实际业务场景。

后续可进一步结合 Python / Machine Learning 建立信用风险预测模型，将当前的描述性 BI 分析扩展为：

> **业务监控 → 风险识别 → 风险预测 → 策略优化**
