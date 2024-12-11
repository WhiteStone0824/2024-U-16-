# -*- coding: utf-8 -*-
require  'CHaserConnect.rb' #呼び出すおまじない


#-------------------------------------------------------------------------------------

#setting = [3,true,21,true,"対人戦用"] #対人戦用

setting = [1024,false,30,false,"対Bot戦用"] #対Bot戦用

#setting = [2,true,24,true,"安全行動"] #安全に行動

#setting = [3,true,4,true,"川合常真"] #川合設定

#setting = [1,false,1,false,"ランダムウォーク"]

lookInterval = setting[0] #でかい数字にすればするほど安全性が下がるが探索スピードが上昇する　lookの間隔
randomWalkHoko = setting[1] #まっすぐランダムウォークをするか？（trueはする。falseはしない。）
resetInterval = setting[2] #方向転換までの時間
anzen = setting[3] #itemをとる前にわざわざlookするか？（trueはする。falseはしない。）

#-------------------------------------------------------------------------------------


# 書き換えない
target = CHaserConnect.new(setting[4]) # ()の中好きな名前
values = Array.new(10)
random = Random.new # 乱数生成

turn = 0
beforeMove = 0

beforebeforeMove = [0,9,6,3]

beforeLook = 0
look = Array.new(10)

nextput = 0
yokoFukuroKouzi = 0

eikyuuSearchUp = false


def _aruku(hoko, target)        # 移動する関数
  case hoko         # hokoの値で処理がきまる
  when 0            # hokoが0のとき
    values = target.walkUp()    # 上に移動する
    beforeMove = 0  # 上に移動したことを記録する
  when 3            # hokoが3のとき
    values = target.walkRight() # 右に移動する
    beforeMove = 3  # 右に移動したことを記録する
  when 6            # hokoが6のとき
    values = target.walkDown() #  下に移動する
    beforeMove = 6  # 下に移動したことを記録する
  when 9            # hokoが9のとき
    values = target.walkLeft() #  左に移動する
    beforeMove = 9  # 左に移動したことを記録する
  end
  return beforeMove # 関数の外に動きの記録を出す
end


def _susumeru(values) # 動める方向の確認
  kabe = Array.new(0) # 可変自滅くん列を作る
  for i in 1..9 do    # iに1〜9までを代入していく
    if values[i] != 2 # valuesの1番地目が2（壁）じゃなければ
      case i
      when 2          # iが2のとき
        kabe.push(0)  # 配列kabeに0を追加する
      when 4          # iが4のとき
        kabe.push(9)  # 配列kabeに9を追加する
      when 6          # iが6のとき
        kabe.push(3)  # 配列kabeに3を追加する
      when 8          # iが8のとき
        kabe.push(6)  # 配列kabeに6を追加する
      end
    end
  end
  return kabe
end

def _kabeyoke(kabe, beforeMove,beforebeforeMove) #  壁を避ける関数
  if kabe.size == 1                    #  もし配列kabeの要素数が1なら
    hoko = kabe[0]                     #  hokoにその方向の値を代入する
  else                                 #  配列kabeの要素数が1でなければ
    beforeMove = (beforeMove + 6) % 12 #  前回の移動の記録から来た方向へ変換
    kabe.delete(beforeMove)            # 来た方向を除いた進める方向の配列にする
    p "行けるところ"
    p kabe
    if kabe.size == 2 || kabe.size == 3
      kabe.delete((beforebeforeMove.tally).min_by { |_, count| count }.first)
      p "選択肢"
      p kabe
      hoko = kabe.sample
      p "選ばれたもの"
      p hoko
      p ""
    else
      hoko = kabe[0]             #  配列からランダムに値を選ぶ
      p "選ばれたもの"
      p hoko
      p ""
    end
  end
  return hoko
end

#--------ここから--------
loop do # ここからループ
  turn += 1
#---------ここから---------

  values = target.getReady
  if values[0] == 0
    break
  end

  #-----ここまで書き換えない-----
  if eikyuuSearchUp == true
    target.searchUp
  else
    if values[2] == 1 #敵が四方にいたら
      target.putUp      #上にputする
    elsif values[4] == 1
      target.putLeft    #左にputする
    elsif values[6] == 1
      target.putRight   #右にputする
    elsif values[8] == 1
      target.putDown    #下にputする
    elsif values[1] == 1#敵が斜めにいたら
      if values[8] != 2
        target.walkDown # 下に歩く
        beforeMove = 6
      elsif values[6] != 2
        target.walkRight # 右に歩く
        beforeMove = 3
      else
        target.lookUp # 上を見る
      end
    elsif values[3] == 1
      if values[4] != 2
        target.walkLeft # 左に歩く
        beforeMove = 9
      elsif values[8] != 2
        target.walkDown # 下に歩く
        beforeMove = 6
      else
        target.lookUp # 上を見る
      end
    elsif values[7] == 1
      if values[6] != 2
        target.walkRight # 右に歩く
        beforeMove = 3
      elsif values[2] != 2
        target.walkUp # 上に歩く
        beforeMove = 0
      else
        target.lookDown # 下を見る
      end
    elsif values[9] == 1
      if values[4] != 2
        target.walkLeft# 左に歩く
        beforeMove = 9
      elsif values[2] != 2
        target.walkUp # 上に歩く
        beforeMove = 0
      else
        target.lookDown # 下を見る
      end
    else
      case yokoFukuroKouzi #横向きの袋小路
      when 0
        case nextput #袋小路もどき対策
        when 0
          case beforeLook #前回lookした向きによって異なる処理をする。0はlookしていない状態。1~4までは初回。4以降は2回目以降
          when 0
            if anzen == true #item前にlookする
              if values[2] == 3 #ここから横のアイテムをとる
                look = target.lookUp
                beforeLook = 1 #上を見たことを記録する
              elsif values[4] == 3
                look = target.lookLeft
                beforeLook = 2 #左を見たことを記録する
              elsif values[6] == 3
                look = target.lookRight
                beforeLook = 3 #右を見たことを記録する
              elsif values[8] == 3
                look = target.lookDown
                beforeLook = 4 #下を見たことを記録する
              else #ここから斜めのアイテムをとる
                if values[1] == 3
                  if values[2] != 2
                    target.walkUp
                    beforeMove = 0
                  elsif values[4] != 2
                    target.walkLeft
                    beforeMove = 9
                  else
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end
                elsif values[3] == 3
                  if values[2] != 2
                    target.walkUp
                    beforeMove = 0
                  elsif values[6] != 2
                    target.walkRight
                    beforeMove = 3
                  else
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end
                elsif values[7] == 3
                  if values[8] != 2
                    target.walkDown
                    beforeMove = 6
                  elsif values[4] != 2
                    target.walkLeft
                    beforeMove = 9
                  else
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end
                elsif values[9] == 3
                  if values[8] != 2
                    target.walkDown
                    beforeMove = 6
                  elsif values[6] != 2
                    target.walkRight
                    beforeMove = 3
                  else
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end#ここまで斜めのアイテムをとる
                else
                  if randomWalkHoko == true #真っすぐランダムウォーク
                    if ((turn % lookInterval) != 1)
                      case beforeMove
                      when 6
                        if values[8] != 2
                          target.walkDown
                          beforeMove = 6
                        else
                          kabe = _susumeru(values)
                          hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                          beforeMove = _aruku(hoko, target)
                        end

                      when 9
                        if values[4] != 2
                          target.walkLeft
                          beforeMove = 9
                        else
                          kabe = _susumeru(values)
                          hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                          beforeMove = _aruku(hoko, target)
                        end

                      when 0
                        if values[2] != 2
                          target.walkUp
                          beforeMove = 0
                        else
                          kabe = _susumeru(values)
                          hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                          beforeMove = _aruku(hoko, target)
                        end

                      when 3
                        if values[6] != 2
                          target.walkRight
                          beforeMove = 3
                        else
                          kabe = _susumeru(values)
                          hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                          beforeMove = _aruku(hoko, target)
                        end
                      end
                    else
                      kabe = _susumeru(values)
                      hoko = _kabeyoke(kabe,beforeMove,beforebeforeMove)
                      case hoko
                      when 6
                        look = target.lookDown
                        beforeLook = 4
                        beforeMove = 6
                      when 9
                        look = target.lookLeft
                        beforeLook = 2
                        beforeMove = 9
                      when 0
                        look = target.lookUp
                        beforeLook = 1
                        beforeMove = 0
                      when 3
                        look = target.lookRight
                        beforeLook = 3
                        beforeMove = 3
                      end
                    end
                  else #真っすぐじゃないランダムウォーク
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end
                end
              end
            else #item前にlookしない
              if values[2] == 3 #ここから横のアイテムをとる
                if ((values[1] == 2 && values[3] == 2)  || (values[1] != 2 && values[3] == 2 && values[4] == 2) || (values[1] == 2 && values[3] != 2 && values[6] == 2) || (values[1] != 2 && values[2] == 3 && values[3] != 2 && values[4] == 2 && values[6] == 2))
                  look = target.lookUp
                  beforeLook = 1 #上を見たことを記録する
                else
                  target.walkUp
                  beforeMove = 0
                end
              elsif values[4] == 3
                if ((values[1] == 2 && values[7] == 2) || (values[1] != 2 && values[2] == 2 && values[7] == 2) || (values[1] == 2 && values[7] != 2 && values[8] == 2) || (values[7] != 2 && values[4] == 3 && values[1] != 2 && values[8] == 2 && values[2] == 2))
                  look = target.lookLeft
                  beforeLook = 2 #左を見たことを記録する
                else
                  target.walkLeft
                  beforeMove = 9
                end
              elsif values[6] == 3
                if ((values[3] == 2 && values[9] == 2) || (values[2] == 2 && values[3] != 2 && values[9] == 2) || (values[8] == 2 && values[9] != 2 && values[3] == 2) || (values[3] != 2 && values[6] == 3 && values[9] != 2 && values[2] == 2 && values[8] == 2))
                  look = target.lookRight
                  beforeLook = 3 #右を見たことを記録する
                else
                  target.walkRight
                  beforeMove = 3
                end
              elsif values[8] == 3
                if ((values[9] == 2 && values[7] == 2) || (values[4] == 2 && values[7] != 2 && values[9] == 2) || (values[6] == 2 && values[9] != 2 && values[7] == 2) || (values[9] != 2 && values[8] == 3 && values[7] != 2 && values[6] == 2 && values[4] == 2))
                  look = target.lookDown
                  beforeLook = 4 #下を見たことを記録する
                else
                  target.walkDown
                  beforeMove = 6
                end #ここまで横のアイテムをとる
              else #ここから斜めのアイテムをとる
                if values[1] == 3
                  if values[2] != 2
                    target.walkUp
                    beforeMove = 0
                  elsif values[4] != 2
                    target.walkLeft
                    beforeMove = 9
                  else
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end
                elsif values[3] == 3
                  if values[2] != 2
                    target.walkUp
                    beforeMove = 0
                  elsif values[6] != 2
                    target.walkRight
                    beforeMove = 3
                  else
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end
                elsif values[7] == 3
                  if values[8] != 2
                    target.walkDown
                    beforeMove = 6
                  elsif values[4] != 2
                    target.walkLeft
                    beforeMove = 9
                  else
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end
                elsif values[9] == 3
                  if values[8] != 2
                    target.walkDown
                    beforeMove = 6
                  elsif values[6] != 2
                    target.walkRight
                    beforeMove = 3
                  else
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end#ここまで斜めのアイテムをとる
                else
                  if randomWalkHoko == true #真っすぐランダムウォーク
                    if ((turn % lookInterval) != 1)
                      case beforeMove
                      when 6
                        if values[8] != 2
                          target.walkDown
                          beforeMove = 6
                        else
                          kabe = _susumeru(values)
                          hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                          beforeMove = _aruku(hoko, target)
                        end

                      when 9
                        if values[4] != 2
                          target.walkLeft
                          beforeMove = 9
                        else
                          kabe = _susumeru(values)
                          hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                          beforeMove = _aruku(hoko, target)
                        end

                      when 0
                        if values[2] != 2
                          target.walkUp
                          beforeMove = 0
                        else
                          kabe = _susumeru(values)
                          hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                          beforeMove = _aruku(hoko, target)
                        end

                      when 3
                        if values[6] != 2
                          target.walkRight
                          beforeMove = 3
                        else
                          kabe = _susumeru(values)
                          hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                          beforeMove = _aruku(hoko, target)
                        end
                      end
                    else
                      kabe = _susumeru(values)
                      hoko = _kabeyoke(kabe,beforeMove,beforebeforeMove)
                      case hoko
                      when 6
                        look = target.lookDown
                        beforeLook = 4
                        beforeMove = 6
                      when 9
                        look = target.lookLeft
                        beforeLook = 2
                        beforeMove = 9
                      when 0
                        look = target.lookUp
                        beforeLook = 1
                        beforeMove = 0
                      when 3
                        look = target.lookRight
                        beforeLook = 3
                        beforeMove = 3
                      end
                    end
                  else #真っすぐじゃないランダムウォーク
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end
                end
              end
            end

          when 1 #上
            if (look.slice(1..-1)).include?(1)
              look = target.lookUp
              beforeLook = 1
              beforeMove = 0
            else#上に敵がいなかったら
              if ((look[7] == 2 && look[8] == 3 && look[9] == 2 && look[5] == 2) || (look[7] == 2 && look[8] == 3 && look[9] == 2 && look[5] != 2 && look[4] == 2 && look[6] == 2 && look[2] == 2))
                if values[6] != 2 || values[8] != 2 || values[4] != 2 #自滅しないか
                  target.putUp
                  beforeLook = 0
                else
                  if (look[7] == 2 && look[8] == 3 && look[9] == 2 && look[5] == 2)
                    target.searchUp
                    eikyuuSearchUp = true
                  else
                    target.walkUp
                    beforeLook = 0
                  end
                end
              elsif look[1] == 2 && look[3] == 2 && look[4] == 2 && look[6] == 2 && look[7] == 2 && look[9] == 2 && look[8] == 3 && look[5] != 2 && look[2] != 2
                look = target.searchUp
                beforeLook = 5
              elsif look[4] == 2 && ((look[5] == 2) || (look[5] != 2 && look[2] == 2) ) && look[6] == 2 && look[7] != 2 && look[8] == 3 && look[9] != 2 && values[4] == 2 && values[6] == 2 #T字
                look = target.lookLeft
                beforeLook = 9
              elsif look[1] == 2 && look[2] != 2 && look[3] == 2 && look[4] == 2 && look[5] != 2 && look[6] == 2 && look[7] != 2 && look[8] == 3 && look[9] != 2 && values[4] == 2 && values[6] == 2
                look = target.searchUp
                beforeLook = 17
              else
                if look[4] == 2 && ((look[5] == 2) || (look[2] == 2 && look[6] == 2 && look[5] != 2)) && look[7] != 2 && look[8] == 3 && look[9] == 2 && values[4] == 2 #L字
                  look = target.lookLeft
                  yokoFukuroKouzi = 1
                elsif look[6] == 2 && ((look[5] == 2) || (look[2] == 2 && look[4] == 2 && look[5] != 2)) && look[9] != 2 && look[8] == 3 && look[7] == 2 && values[6] == 2 #L字
                  look = target.lookRight
                  yokoFukuroKouzi = 1
                elsif look[1] == 2 && look[2] != 2 && look[3] == 2 &&  look[4] == 2 && look[5] != 2 && look[6] == 2 && look[9] == 2 && look[8] == 3 && look[7] != 2 && values[4] == 2#長いL字（左）
                  look = target.searchUp
                  yokoFukuroKouzi = 5
                elsif look[1] == 2 && look[2] != 2 && look[3] == 2 &&  look[4] == 2 && look[5] != 2 && look[6] == 2 && look[7] == 2 && look[8] == 3 && look[9] != 2 && values[6] == 2 #長いL字（右）
                  look = target.searchUp
                  yokoFukuroKouzi = 9
                else
                  if values[2] != 2 # 上に壁がなかったら
                    if ((look[7] == 2 && look[9] == 2 && look[5] == 2) || (look[7] == 2 && look[9] == 2 && look[4] == 2 && look[6] == 2 && look[2] == 2 && look[5] != 2 && look[8] == 0))#その周りが壁だった時
                      if values[6] != 2 || values[8] != 2 || values[4] != 2 #自滅しないか
                        target.putUp
                        beforeLook = 0
                      else
                        target.searchUp
                        eikyuuSearchUp = true
                      end
                    else
                      target.walkUp #歩く
                      beforeMove = 0
                      if look[4] == 2 && look[6] == 2 && look[2] == 2 && look[5] != 2
                        nextput = beforeLook
                      end
                    end
                  else #ランダムウォーク
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end
                beforeLook = 0
                end
              end
            end

          when 2 #左
            if (look.slice(1..-1)).include?(1)
              look = target.lookLeft
              beforeLook = 2
              beforeMove = 9
            else#左に敵がいなかったら
              if ((look[3] == 2 && look[6] == 3 && look[9] == 2 && look[5] == 2) || (look[3] == 2 && look[6] == 3 && look[9] == 2 && look[5] != 2 && look[2] == 2 && look[8] == 2 && look[4] == 2))
                if values[2] != 2 || values[8] != 2 || values[6] != 2 #自滅しないか
                  target.putLeft
                  beforeLook = 0
                else
                  if (look[3] == 2 && look[6] == 3 && look[9] == 2 && look[5] == 2)
                    target.searchUp
                    eikyuuSearchUp = true
                  else
                    target.walkLeft
                    beforeLook = 0
                  end
                end
              elsif look[1] == 2 && look[3] == 2 && look[2] == 2 && look[8] == 2 && look[7] == 2 && look[9] == 2 && look[6] == 3 && look[5] != 2 && look[4] != 2
                look = target.searchLeft
                beforeLook = 6
              elsif look[8] == 2 && ((look[5] == 2) || (look[5] != 2 && look[4] == 2)) && look[2] == 2 && look[9] != 2 && look[6] == 3 && look[3] != 2 && values[8] == 2 && values[2] == 2
                look = target.lookDown
                beforeLook = 10
              elsif look[7] == 2 && look[4] != 2 && look[1] == 2 && look[8] == 2 && look[5] != 2 && look[2] == 2 && look[9] != 2 && look[6] == 3 && look[3] != 2 && values[8] == 2 && values[2] == 2
                look = target.searchLeft
                beforeLook = 18
              else
                if look[2] == 2 && look[3] != 2 && ((look[5] == 2) || (look[4] == 2 && look[8] == 2 && look[5] != 2)) && look[6] == 3 && look[9] == 2 && values[2] == 2 #上左
                  look = target.lookUp
                  yokoFukuroKouzi = 2
                elsif look[3] == 2 && ((look[5] == 2) || (look[2] == 2 && look[4] == 2 && look[5] != 2)) && look[6] == 3 && look[8] == 2 && look[9] != 2 && values[8] == 2
                  look = target.lookDown
                  yokoFukuroKouzi = 2
                elsif look[7] == 2 && look[4] != 2 && look[1] == 2 &&  look[8] == 2 && look[5] != 2 && look[2] == 2 && look[3] == 2 && look[6] == 3 && look[9] != 2 && values[8] == 2#長いL字（左）
                  look = target.searchLeft
                  yokoFukuroKouzi = 6
                elsif look[7] == 2 && look[4] != 2 && look[1] == 2 &&  look[8] == 2 && look[5] != 2 && look[2] == 2 && look[9] == 2 && look[6] == 3 && look[3] != 2 && values[2] == 2 #長いL字（右）
                  look = target.searchLeft
                  yokoFukuroKouzi = 10
                else
                  if values[4] != 2 # 左に壁がなかったら
                    if ((look[3] == 2 && look[9] == 2 && look[5] == 2) || (look[2] == 2 && look[3] == 2 && look[4] == 2 && look[8] == 2 && look[9] == 2 && look[5] != 2 && look[6] == 0))#その周りが壁だった時
                      if values[2] != 2 || values[8] != 2 || values[6] != 2 #自滅しないか
                        target.putLeft
                        beforeLook = 0
                      else
                        target.searchUp
                        eikyuuSearchUp = true
                      end
                    else
                      target.walkLeft #歩く
                      beforeMove = 9
                      if look[4] == 2 && look[2] == 2 && look[8] == 2 && look[5] != 2
                        nextput = beforeLook
                      end
                    end
                  else #ランダムウォーク
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end
                  beforeLook = 0
                end
              end
            end

          when 3 #右
            if (look.slice(1..-1)).include?(1)
              look = target.lookRight
              beforeLook = 3
              beforeMove = 3
            else#右に敵がいなかったら
              if ((look[7] == 2 && look[4] == 3 && look[1] == 2 && look[5] == 2) || (look[7] == 2 && look[4] == 3 && look[1] == 2 && look[5] != 2 && look[2] == 2 && look[8] == 2 && look[6] == 2) )
                if values[2] != 2 || values[8] != 2 || values[4] != 2 #自滅しないか
                  target.putRight
                  beforeLook = 0
                else
                  if (look[7] == 2 && look[4] == 3 && look[1] == 2 && look[5] == 2)
                    target.searchUp
                    eikyuuSearchUp = true
                  else
                    target.walkRight
                    beforeLook = 0
                  end
                end
              elsif look[1] == 2 && look[3] == 2 && look[2] == 2 && look[8] == 2 && look[7] == 2 && look[9] == 2 && look[4] == 3 && look[5] != 2 && look[6] != 2
                look = target.searchRight
                beforeLook = 7
              elsif look[2] == 2 && ((look[5] == 2) || (look[5] != 2 && look[6] == 2)) && look[8] == 2 && look[1] != 2 && look[4] == 3 && look[7] != 2 && values[2] == 2 && values[8] == 2
                look = target.lookUp
                beforeLook = 11
              elsif look[3] == 2 && look[6] != 2 && look[9] == 2 && look[2] == 2 && look[5] != 2 && look[8] == 2 && look[1] != 2 && look[4] == 3 && look[7] != 2 && values[2] == 2 && values[8] == 2
                look = target.searchRight
                beforeLook = 19
              else
                if look[2] == 2 && look[1] != 2 && ((look[5] == 2) || (look[6] == 2 && look[8] == 2 && look[5] != 2)) && look[4] == 3 && look[7] == 2 && values[2] == 2
                  look = target.lookUp
                  yokoFukuroKouzi = 3
                elsif look[1] == 2 && ((look[5] == 2) || (look[6] == 2 && look[2] == 2 && look[5] != 2)) && look[4] == 3 && look[8] == 2 && look[7] != 2 && values[8] == 2
                  look = target.lookDown
                  yokoFukuroKouzi = 3
                elsif look[3] == 2 && look[6] != 2 && look[9] == 2 &&  look[2] == 2 && look[5] != 2 && look[8] == 2 && look[7] == 2 && look[4] == 3 && look[1] != 2 && values[2] == 2#長いL字（左）
                  look = target.searchRight
                  yokoFukuroKouzi = 7
                elsif look[3] == 2 && look[6] != 2 && look[9] == 2 &&  look[2] == 2 && look[5] != 2 && look[8] == 2 && look[1] == 2 && look[4] == 3 && look[7] != 2 && values[8] == 2 #長いL字（右）
                  look = target.searchRight
                  yokoFukuroKouzi = 11
                else
                  if values[6] != 2 # 右に壁がなかったら
                    if ((look[1] == 2 && look[7] == 2 && look[5] == 2) || (look[1] == 2 && look[2] == 2 && look[6] == 2 && look[7] == 2 && look[8] == 2 && look[5] != 2 && look[4] == 0))#その周りが壁だった時
                      if values[2] != 2 || values[8] != 2 || values[4] != 2 #自滅しないか
                        target.putRight
                        beforeLook = 0
                      else
                        target.searchUp
                        eikyuuSearchUp = true
                      end
                    else
                      target.walkRight #歩く
                      beforeMove = 3
                      if look[2] == 2 && look[6] == 2 && look[8] == 2 && look[5] != 2
                        nextput = beforeLook
                      end
                    end
                  else #ランダムウォーク
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end
                beforeLook = 0
                end
              end
            end

          when 4 #下
            if (look.slice(1..-1)).include?(1)
              look = target.lookDown
              beforeLook = 4
              beforeMove = 6
            else#下に敵がいなかったら
              if ((look[1] == 2 && look[2] == 3 && look[3] == 2 && look[5] == 2) || (look[1] == 2 && look[2] == 3 && look[3] == 2 && look[5] != 2 && look[4] == 2 && look[6] == 2 && look[8] == 2) )#袋小路
                if values[2] != 2 || values[6] != 2 || values[4] != 2 #自滅しないか
                  target.putDown
                  beforeLook = 0
                else
                  if (look[1] == 2 && look[2] == 3 && look[3] == 2 && look[5] == 2)
                    target.searchUp
                    eikyuuSearchUp = true
                  else
                    target.walkDown
                    beforeLook = 0
                  end
                end
              elsif look[1] == 2 && look[3] == 2 && look[4] == 2 && look[6] == 2 && look[7] == 2 && look[9] == 2 && look[2] == 3 && look[5] != 2 && look[8] != 2
                look = target.searchDown
                beforeLook = 8
              elsif look[6] == 2 && ((look[5] == 2) || (look[5] != 2 && look[8] == 2)) && look[4] == 2 && look[3] != 2 && look[2] == 3 && look[1] != 2 && values[6] == 2 && values[4] == 2
                look = target.lookRight
                beforeLook = 12
              elsif look[9] == 2 && look[8] != 2 && look[7] == 2 && look[6] == 2 && look[5] != 2 && look[4] == 2 && look[3] != 2 && look[2] == 3 && look[1] != 2 && values[6] == 2 && values[4] == 2
                look = target.searchDown
                beforeLook = 20
              else
                if look[1] != 2 && look[2] == 3 && look[3] == 2 && look[4] == 2 && ((look[5] == 2) || (look[8] == 2 && look[6] == 2 && look[5] != 2)) && values[4] == 2
                  look = target.lookLeft
                  yokoFukuroKouzi = 4
                elsif look[1] == 2 && look[2] == 3 && look[3] != 2 && ((look[5] == 2) || (look[8] == 2 && look[6] == 2 && look[5] != 2)) && look[6] == 2 && values[6] == 2
                  look = target.lookRight
                  yokoFukuroKouzi = 4
                elsif look[9] == 2 && look[8] != 2 && look[7] == 2 &&  look[6] == 2 && look[5] != 2 && look[4] == 2 && look[1] == 2 && look[2] == 3 && look[3] != 2 && values[6] == 2#長いL字（左）
                  look = target.searchRight
                  yokoFukuroKouzi = 7
                elsif look[9] == 2 && look[8] != 2 && look[7] == 2 &&  look[6] == 2 && look[5] != 2 && look[4] == 2 && look[7] == 2 && look[2] == 3 && look[1] != 2 && values[4] == 2 #長いL字（右）
                  look = target.searchRight
                  yokoFukuroKouzi = 11
                else
                  if values[8] != 2 # 下に壁がなかったら
                    if ((look[1] == 2 && look[3] == 2 && look[5] == 2) || (look[1] == 2 && look[3] == 2 && look[4] == 2 && look[6] == 2 && look[8] == 2 && look[5] != 2 && look[2] == 0))#その周りが壁だった時
                      if values[6] != 2 || values[2] != 2 || values[4] != 2 #自滅しないか
                        target.putDown
                        beforeLook = 0
                      else
                        target.searchUp
                        eikyuuSearchUp = true
                      end
                    else
                      target.walkDown #歩く
                      beforeMove = 6
                      if look[4] == 2 && look[6] == 2 && look[8] == 2 && look[5] != 2
                        nextput = beforeLook
                      end
                    end
                  else #ランダムウォーク
                    kabe = _susumeru(values)
                    hoko = _kabeyoke(kabe, beforeMove,beforebeforeMove)
                    beforeMove = _aruku(hoko, target)
                  end
                  beforeLook = 0
                end
              end
            end

          when 5
            if look[4] == 2
              if values[6] != 2 || values[8] != 2 || values[4] != 2 #自滅しないか
                target.putUp
              else
                target.walkUp
              end
            else
              target.walkUp
            end
            beforeLook = 0

          when 6
            if look[4] == 2
              if values[2] != 2 || values[8] != 2 || values[6] != 2 #自滅しないか
                target.putLeft
              else
                target.walkLeft
              end
            else
              target.walkLeft
            end
            beforeLook = 0

          when 7
            if look[4] == 2
              if values[2] != 2 || values[8] != 2 || values[4] != 2 #自滅しないか
                target.putRight
              else
                target.walkRight
              end
            else
              target.walkRight
            end
            beforeLook = 0

          when 8
            if look[4] == 2
              if values[2] != 2 || values[6] != 2 || values[4] != 2 #自滅しないか
                target.putDown
              else
                target.walkDown
              end
            else
              target.walkDown
            end
            beforeLook = 0

          when 9
            if look[2] != 2
              target.walkUp
              beforeLook = 0
            else
              look = target.lookRight
              beforeLook = 13
            end

          when 10
            if look[4] != 2
              target.walkRight
              beforeLook = 0
            else
              look = target.lookUp
              beforeLook = 14
            end

          when 11
            if look[6] != 2
              target.walkLeft
              beforeLook = 0
            else
              look = target.lookDown
              beforeLook = 15
            end

          when 12
            if look[8] != 2
              target.walkDown
              beforeLook = 0
            else
              look = target.lookLeft
              beforeLook = 16
            end

          when 13
            if look[2] == 2
              if values[6] != 2 || values[8] != 2 || values[4] != 2 #自滅しないか
                target.putUp
              else
                target.walkUp
              end
            else
              target.walkUp
            end
            beforeLook = 0

          when 14
            if look[4] == 2
              if values[2] != 2 || values[8] != 2 || values[4] != 2 #自滅しないか
                target.putRight
              else
                target.walkRight
              end
            else
              target.walkRight
            end
            beforeLook = 0

          when 15
            if look[6] == 2
              if values[2] != 2 || values[8] != 2 || values[6] != 2 #自滅しないか
                target.putLeft
              else
                target.walkLeft
              end
            else
              target.walkLeft
            end
            beforeLook = 0

          when 16
            if look[8] == 2
              if values[2] != 2 || values[4] != 2 || values[6] != 2 #自滅しないか
                target.putDown
              else
                target.walkDown
              end
            else
              target.walkDown
            end
            beforeLook = 0

          when 17
            if look[4] == 2
              look = target.lookLeft
              beforeLook = 9
            else
              target.walkUp
            end

          when 18
            if look[4] == 2
              look = target.lookDown
              beforeLook = 10
            else
              target.walkLeft
            end

          when 19
            if look[4] == 2
              look = target.lookUp
              beforeLook = 11
            else
              target.walkRight
            end

          when 20
            if look[4] == 2
              look = target.lookRight
              beforeLook = 12
            else
              target.walkDown
            end

          end

        when 1 #上袋小路もどき
          if values[6] != 2 || values[8] != 2 || values[4] != 2 #自滅しないか
            target.putUp
            beforeLook = 0
          else
            target.searchUp
            eikyuuSearchUp = true
          end
          nextput = 0

        when 2 #左
          if values[2] != 2 || values[8] != 2 || values[6] != 2 #自滅しないか
            target.putLeft
            beforeLook = 0
          else
            target.searchUp
            eikyuuSearchUp = true
          end
          nextput = 0

        when 3 #右
          if values[2] != 2 || values[8] != 2 || values[4] != 2 #自滅しないか
            target.putRight
            beforeLook = 0
          else
            target.searchUp
            eikyuuSearchUp = true
          end
          nextput = 0

        when 4 #下ここまで
          if values[6] != 2 || values[2] != 2 || values[4] != 2 #自滅しないか
            target.putDown
            beforeLook = 0
          else
            target.searchUp
            eikyuuSearchUp = true
          end
          nextput = 0
        end

      when 1 #上L字袋小路
        if look[2] == 2
          if values[6] != 2 || values[8] != 2 || values[4] != 2 #自滅しないか
            target.putUp
            yokoFukuroKouzi = 0
          else
            target.walkUp
            eikyuuSearchUp = true
          end
        else
          target.walkUp
          yokoFukuroKouzi = 0
        end

      when 2 #左
        if look[4] == 2
          if values[6] != 2 || values[8] != 2 || values[2] != 2 #自滅しないか
            target.putLeft
            yokoFukuroKouzi = 0
          else
            target.walkLeft
            eikyuuSearchUp = true
          end
        else
          target.walkLeft
          yokoFukuroKouzi = 0
        end

      when 3 #右
        if look[6] == 2
          if values[4] != 2 || values[8] != 2 || values[2] != 2 #自滅しないか
            target.putRight
            yokoFukuroKouzi = 0
          else
            target.walkRight
            eikyuuSearchUp = true
          end
        else
          target.walkRight
          yokoFukuroKouzi = 0
        end

      when 4 #下
        if look[8] == 2
          if values[6] != 2 || values[4] != 2 || values[2] != 2 #自滅しないか
            target.putDown
            yokoFukuroKouzi = 0
          else
            target.walkDown
            eikyuuSearchUp = true
          end
        else
          target.walkDown
          yokoFukuroKouzi = 0
        end

      when 5
        if look[4] == 2
          look = target.lookLeft
          yokoFukuroKouzi = 1
        else
          target.walkUp
          yokoFukuroKouzi = 0
        end

      when 6
        if look[4] == 2
          look = target.lookDown
          yokoFukuroKouzi = 2
        else
          target.walkLeft
          yokoFukuroKouzi = 0
        end

      when 7
        if look[4] == 2
          look = target.lookUp
          yokoFukuroKouzi = 3
        else
          target.walkRight
          yokoFukuroKouzi = 0
        end

      when 8
        if look[4] == 2
          look = target.lookRight
          yokoFukuroKouzi = 4
        else
          target.walkUp
          yokoFukuroKouzi = 0
        end

      when 9
        if look[4] == 2
          look = target.lookRight
          yokoFukuroKouzi = 1
        else
          target.walkDown
          yokoFukuroKouzi = 0
        end

      when 10
        if look[4] == 2
          look = target.lookUp
          yokoFukuroKouzi = 2
        else
          target.walkLeft
          yokoFukuroKouzi = 0
        end

      when 11
        if look[4] == 2
          look = target.lookDown
          yokoFukuroKouzi = 3
        else
          target.walkRight
          yokoFukuroKouzi = 0
        end

      when 12
        if look[4] == 2
          look = target.lookLeft
          yokoFukuroKouzi = 4
        else
          target.walkDown
          yokoFukuroKouzi = 0
        end

      end #ここまで
    end
  end

  beforebeforeMove.push(beforeMove)

  if( turn % resetInterval ) == 0
    beforebeforeMove = [0,3,6,9]
    p "リセット"
    turn = 0
  else
    p "リセットまで"
    p resetInterval - turn
    p "ターン"
  end

  p beforebeforeMove


  #---------ここから---------
  if values[0] == 0
    break
  end
end # ループここまで
target.close
#-----ここまで書き換えない-----
