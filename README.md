# MultipleEncoding — jamovi module

Module jamovi xử lý các biến chứa **nhiều giá trị** (ví dụ câu hỏi khảo sát
Google Forms hay các nền tảng khảo sát khác, nơi một ô có thể chứa nhiều lựa
chọn phân cách bởi dấu `,` hoặc `;`).

> Nhập hoặc tách câu hỏi có nhiều lựa chọn.

---

## Các phân tích (Analyses)

Module gồm 3 phân tích, đều nằm trong menu **Data**.

### 1. Multiple Encoding

Chuyển đổi một biến chứa nhiều giá trị phân cách thành **nhiều cột nhị phân
(0/1)** — mỗi giá trị duy nhất trở thành một cột mới.

- **Variable to Split**: biến cần tách.
- **Separator**: ký tự phân cách (mặc định `,`).
- **Run**: bấm nút để thực thi.

Các cải tiến so với OneHotEncoding gốc:

| Cải tiến | Mô tả |
| --- | --- |
| Trim đúng cách | Chỉ `trimws()` từng phần **sau khi tách**, giữ nguyên khoảng trắng bên trong giá trị. |
| Hiệu năng | Gọi `strsplit()` **một lần** trên toàn bộ cột + so khớp vector hóa (`%in%`), thay vì tách lại từng dòng. |
| Mô tả gọn | Mô tả cột chỉ chứa **giá trị duy nhất**, không chèn câu dài dòng. |
| Nút Run | Có nút **Run** riêng; phân tích chỉ chạy khi được bấm. |

### 2. Merge Variables

Ghép giá trị text của **nhiều biến** thành **một biến mới**, các giá trị cách
nhau bởi dấu `;`.

- **Variables to Merge**: danh sách các biến cần ghép (chọn nhiều).
- **Target Variable Name**: tên biến mới do bạn nhập.
- **Run**: bấm nút để thực thi.

Các phần rỗng hoặc `NA` sẽ được **bỏ qua**. Ví dụ:

| a | b | c | merged (`Target = mergedVar`) |
| --- | --- | --- | --- |
| hello | world |  | `hello;world` |
| foo | NA | baz | `foo;baz` |
| NA | bar | qux | `bar;qux` |
| x | y | z | `x;y;z` |

### 3. Weights to Dataset

Nhân bản vật lý các dòng dữ liệu theo một biến weight liên tục, tạo ra một
dataset mới đặt tên `dataset_weight`.

Đọc toàn bộ dataset hiện tại, với mỗi dòng lấy giá trị của biến weight `w`,
sau đó **vật lý** nhân bản dòng đó `w` lần vào dataset kết quả:

| ID | Weight | Value |  →  | ID | Weight | Value |
|----|--------|-------|----|----|--------|-------|
| 1  | 3      | A     |    | 1  | 3      | A     |
| 2  | 1      | B     |    | 1  | 3      | A     |
| 3  | 2      | C     |    | 1  | 3      | A     |
|    |        |       |    | 2  | 1      | B     |
|    |        |       |    | 3  | 2      | C     |
|    |        |       |    | 3  | 2      | C     |

Đây là **PHYSICAL ROW REPLICATION**, không phải tạo cột frequency / survey
weight. Dataset gốc không bị thay đổi.

---

## Cách sử dụng

1. Trong jamovi: **Data → Weights to Dataset**.
2. Chọn đúng **1 biến weight** (chỉ cho phép biến numeric/continuous).
3. Nhấn **Create**.
4. Khu vực **Status** hiển thị kết quả, ví dụ:

   ```
   Dataset created successfully: dataset_weight.omv
   Rows before: 3  ->  Rows after: 6
   Location: /path/to/dataset_weight.omv
   The new dataset has been opened in a new jamovi window.
   ```

5. Dataset mới tự động mở trong một cửa sổ jamovi khác (qua `jmvReadWrite`), hoặc
   có thể mở thủ công (**File → Open**) nếu tự động mở thất bại.

---

## Cài đặt

Mở jamovi → **Analyses** → **Data** → chọn **Multiple Encoding** / **Merge
Variables** (sau khi module đã được cài).

Hoặc build từ source (xem bên dưới) rồi cài file `.jmo` qua
**jamovi → Modules → Install module from file…**.

---

## Build từ source

Yêu cầu: **R**, package **jmvtools**, và **jamovi** đã cài (compiler `jmc` được
đóng gói sẵn trong jamovi).

Từ thư mục **cha** của thư mục module:

```r
jmvtools::install("MultipleEncoding")
```

Lệnh này biên dịch R package + UI, sinh ra `MultipleEncoding_1.0.0.jmo` và tự
động cài vào jamovi.

### Build cho nhiều nền tảng

Module có thể build cho `macos/arm64`, `macos/x64`, `linux/arm64`,
`linux/x64`, `win64`. Xem tài liệu skill **jamovi-module-dev**
(`references/compiler.md`) và script `scripts/build-module.sh` để biết ma trận
từng nền tảng. Nguyên tắc: cùng một lệnh `jmvtools::install`, chỉ khác **R
runtime của jamovi tương ứng với từng hệ điều hành / kiến trúc**.

---

## Cấu trúc module

```
MultipleEncoding/
├── DESCRIPTION, NAMESPACE
├── R/
│   ├── multipleencoding.b.R     # logic Multiple Encoding (sửa tay)
│   ├── mergevariables.b.R       # logic Merge Variables (sửa tay)
│   └── *.h.R                    # tự sinh bởi compiler, không sửa
└── jamovi/
    ├── 0000.yaml                # manifest + danh sách analyses
    ├── multipleencoding.{a,r,u}.yaml
    └── mergevariables.{a,r,u}.yaml
```

> Lưu ý: file `*.h.R`, `*.u.yaml` và `*.js` bị compiler **ghi đè** mỗi lần
> build. Chỉ sửa `0000.yaml`, `*.a.yaml`, `*.r.yaml` và `*.b.R`.

---

## License

GPL-3.
