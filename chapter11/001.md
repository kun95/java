### 0、抛出一个问题

如果每当给定一个对象A、一个字段名称b和一个值c，程序需要将对象A的b字段设置为值c，那么程序该怎么写呢？注意：名称b是可以随便变化的哦。

### 1. 反射的作用

- 可以在运行时分析类
- 在运行时查看对象
- 调用指定名称的方法

一般来说，中间件或是框架的开发人员需要经常跟反射打交道。甚至有人把反射称为是框架的基石。业务开发人员在编写一些动态的代码时，也可能会用到反射。

### 2. 相关的类

- Class 类的类
- Method  方法类
- Field 字段类
- Constructor 构造器类
- Modifier 描述符类

### 3. Class 类

- getFields 获取类提供的public的域，包括超类的public域
- getMethods 获取类提供的pubulic方法，包括超类的public方法
- getConstructor 获取类提供的public构造器，包括超类的构造器
- getDeclaredFields 获取类提供的除超类外的全部域
- getDeclaredMethods 获取类提供的除超类外的全部方法
- getDeclaredConstructor 获取类提供的除超类外的构造器

### 4. 代码示例

#### 4.1 打印类的基本信息 名称、简称、限定符等

```
 private static void printClass(String className) throws ClassNotFoundException {
        // 获取类
        Class<?> cl = Class.forName(className);

        // 获取类的超类 当cl为Object的时候 那么superclass为空  毕竟Object没有父类了
        Class<?> superclass = cl.getSuperclass();

        // 获得子类的所有限定符
        String classModifiers = Modifier.toString(cl.getModifiers());
        System.out.println("类限定符："+classModifiers);

        // 获得超类的所有限定符
        if(superclass != null && superclass != Object.class){
            String superClassModifers = Modifier.toString(superclass.getModifiers());
            System.out.println("父类限定符："+superClassModifers);
        }

        // 获取子类名称
        String name = cl.getName();
        String simpleName = cl.getSimpleName();
        System.out.println("类名称："+name+",simpleName : " + simpleName);

        // 父类名称
        if(superclass != null && superclass != Object.class){
            String superclassName = superclass.getName();
            String superSimpleName = superclass.getSimpleName();
            System.out.println("超类名称："+superclassName+", simpleSuperName : "+superSimpleName);
        }
    }
```

#### 4.2 打印类字段信息

```
   private static void printFields(String className) throws ClassNotFoundException {
        // 获取类
        Class<?> cl = Class.forName(className);
        Field[] declaredFields = cl.getDeclaredFields();
        for (Field field : declaredFields){
            Class<?> type = field.getType();
            String name = type.getName();
            System.out.println("字段类型名称："+name);
            String fieldModifer = Modifier.toString(field.getModifiers());
            System.out.println("字段限定符："+fieldModifer);
        }
   }
```

#### 4.3 打印类中的方法

```
private static void printMethods(String className) throws ClassNotFoundException {
        // 获取类
        Class<?> cl = Class.forName(className);
        Method[] declaredMethods = cl.getDeclaredMethods();
        for(Method method:declaredMethods){

            // 获取方法返回类型
            Class<?> returnType = method.getReturnType();
            System.out.println("方法返回类型名："+returnType.getName());

            // 获取方法的限定符
            String modifers = Modifier.toString(method.getModifiers());
            System.out.println("方法限定符："+modifers);

            // 获取方法的参数类型
            Class<?>[] parameterTypes = method.getParameterTypes();
            for(Class parametrType : parameterTypes){
                System.out.println("入参类型名："+parametrType.getName());
            }
        }
 }
```

#### 4.4 打印类的构造器

```
    private static void printConstructor(String className) throws ClassNotFoundException {
        // 获取类
        Class<?> cl = Class.forName(className);
        Constructor<?>[] declaredConstructors = cl.getDeclaredConstructors();

        for(Constructor constructor : declaredConstructors){
            String name = constructor.getName();
            System.out.println("构造器名称："+name);

            String modifers = Modifier.toString(constructor.getModifiers());
            System.out.println("构造器限定符："+modifers);

            Class[] parameterTypes = constructor.getParameterTypes();
            for(Class cs : parameterTypes){
                String paramName = cs.getName();
                System.out.println("构造器参数类型："+paramName);
            }
        }
    }
```

### 5. 在运行时分析对象

#### 5.1 运行时获取指定域的值

```
// User 类的结构
User user = new User();
user.setName("ming");
user.setAge(20);

// 现在假设不知道user里面存的是什么数据，并且我们想要获取User中指定字段/域的值 以获取name字段的值为例
Class cl = user.getClass();
Field nameField = cl.getDeclaredField("name");
Object value = nameField.get(user);  // 1
```

注意，如果在User类中name字段是私有的话，那么 1 代码处将会抛出 `IllegalAccessibleException`的异常。这是因为：反射机制的默认行为受限于java的访问权限。为了能够访问到私有的变量或是方法，我们可以在调用Field，Method，Constuctor的相关方法获取数据之前，先调用`setAccessible` 方法。

#### 5.2 获取值时候的类型转换

从1处的代码可以看出，get方法返回的结果是个Object，如果name本身是String类型，那么将其赋给一个Object便没什么问题，但是如果name本身是个int类型呢？此时便会出现问题。

现在用代码实现一个工具类，可以将任意一个Object类型的数据转成字符串，其中便涉及到类型转换的问题

```
 private List<Object> visited = new ArrayList();

    public String toString(Object object){

        if(object == null){
            return "null";
        }

        if(visited.contains(object)){
            return "...";
        }

        visited.add(object);

        // 如果对象本质是字符串类型的 那么直接转成字符串返回
        Class<?> cl = object.getClass();
        if(cl == String.class){
            return (String) object;
        }

        // 如果对象本质是数组类型的
        if(cl.isArray()){
            String r = cl.getComponentType() + "[]{";

            for(int i = 0;i< Array.getLength(object);i++){
                if(i > 0){
                    r += ",";
                }

                Object val = Array.get(object, i);
                if(cl.getComponentType().isPrimitive()){
                    r += val;
                }else {
                    r += toString(val);
                }
            }

            return r + "}";
        }


        String name = cl.getName();
        do {
            name += "[";
            Field[] declaredFields = cl.getDeclaredFields();
            // 将所有的字段的访问权限都打开
            AccessibleObject.setAccessible(declaredFields,true);

            for(Field field:declaredFields){
                if(!Modifier.isStatic(field.getModifiers())){
                    if(!name.endsWith("[")){
                        name += ",";
                    }

                    name += field.getName() + "=";

                    Class<?> fieldType = field.getType();
                    try {
                        Object val = field.get(object);

                        if(fieldType.isPrimitive()){
                            name += val;
                        }else {
                            name += toString(val);
                        }
                    } catch (IllegalAccessException e) {
                        e.printStackTrace();
                    }
                }
            }

            name += "]";

            cl = cl.getSuperclass();
        }while (cl != null);


        return name;
    }
```

代码的关键就是：通过isPrimitive判断是否是基本类型，如果是基本类型，那么直接通过+号拼接就可以转成String。

如果是非基本类型，那么通过一定的规则生成String类型。

### 6. 拷贝数组

这个也是反射的功能之一，仔细阅读以下两段数组拷贝的代码

```
public static Object[] badCopyArray(Object[] srcArray,int newLength){
	Object[] newArray = new Object[newLength];
	System.arraycopy(srcArray,0,newArray,0,Math.min(srcArray.length,newLength));
	return newArray;
}
```

```
public static Object goodCopyArray(Object srcArray,int newLength){
	Class cl =	srcArray.getClass();
	if(!cl.isArray()){
		return null;
	}
	
	Class componentType =	cl.getComponentType();
	int length = Array.getLength(srcArray);
	Object newArray = Array.newInstance(componentType,newLength);
	System.arraycopy(srcArray,0,newArray,0,Math.min(length,newLength));
	return newArray;
}
```

仔细对比发现，下面一个接受的参数是Object，但是上面一个接受的参数是Object[] 。

当我们想传入一个 int[] 这种数组的时候，如果使用上面一种就会报错，但是下面一个就不会。

并且，上面一个转成的数组无法再转回原数组。

```
Person haha = new Person("haha", 100);
Person haha2 = new Person("haha", 101);
Person haha3 = new Person("haha", 130);
Person haha4 = new Person("haha", 104);

Person[] persons = new Person[]{haha,haha2,haha3,haha4};
Object[] badObjects = badCopyArray(persons, 10);
        
// 这句代码将会报错，因为badObjects无法再转回Person[]了
System.out.println((Person[])badObjects);

Object goodObjects = goodCopyArray(persons, 10);
        
// 这句代码是OK的
System.out.println((Person[])goodObjects);
```



### 7. 动态调用指定的方法

首先，需要获取到指定方法（获取Method）

```
Method m1 = Employee.class.getMethod("getName");
Method m2 = Employee.class.getMethod("raiseSalary",double.class);
```

然后，调用该方法

```
// 如果m2是个静态方法，那么不需要传对象，第一个参数就为空
m2.invoke(null,100);
// 如果m2是个实例方法，那么就需要传对象
m2.invoke(对象实例,100);

后面的参数都为调用方法时的入参。
```

